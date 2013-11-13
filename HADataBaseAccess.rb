require 'rubygems'
require 'dbi'
require 'net/http'
require 'uri'
require 'xmlsimple'
require 'json'
require 'HADataBaseAccess'
require 'mysql'
require 'HAMsgProcessing'

class HADataBaseAccess
		
	def initialize(db)
		@partnerCode = "CLM_0"
		@partnerID = "C452075"
		@accessMethodCode = "CPL"
		
		@adminDatabase = "DBI:Mysql:cotillion_admin:dev-admin.cotillioncloud.com"
		@adminDatabaseUser = "cotillion"
		@adminDatabasePassword = "Str!ngD3vDB"	
		
		@invDatabase = "DBI:Mysql:cotillion_inventory_processing:dev-inventory.cotillioncloud.com"
		@invDatabaseUser = "cotillion"
		@invDatabasePassword = "Str!ngD3vDB"	
		
		#@adminDatabase = "DBI:Mysql:cotillion_admin:string-master.cotillioncloud.com"
		#@adminDatabaseUser = "cotillion"
		#@adminDatabasePassword = "97apr7zukaba"	
		
		#@invDatabase = "DBI:Mysql:cotillion_inventory_processing:inventory-master.cotillioncloud.com"
		#@invDatabaseUser = "cotillion"
		#@invDatabasePassword = "97apr7zukaba"	
		
		@dbname = db
		@dbConnect = ""
		@dbResults = ""
		@dealerlocation = 0
		@carfax = 0
		@timestamp = 0
		
		@msg = HAMsgProcessing.new()
		
		getDBconnect()
	end
	
	def connectToDB()
		begin
			case @dbname
			when 'admin'
				@dbConnect = DBI.connect(@adminDatabase, @adminDatabaseUser, @adminDatabasePassword)
			when 'inv'
				@dbConnect = DBI.connect(@invDatabase, @invDatabaseUser, @invDatabasePassword)
			else
				msgStr = "An error occurred in database access. Bad connect to type. You gave me #{@dbname} -- I have no idea what to do with that."
				@msg.processMsg("error", "severe", msgStr)
			end	
		rescue DBI::DatabaseError => e
			msgStr = "An DB error occurred trying to create databse connection.  dbname = #{@dbname}. Error message: #{e.errstr}"
			@msg.processMsg("error", "severe", msgStr)
		end
	end  
	
	def getDBconnect()
		#connect to db bases on instance variables
		connectToDB()
		
		@dbConnect
	end
	
	def selectLocations()
		begin
			@dbResults = @dbConnect.select_all("select 		entity_configuration,
    		                    locs.*
                                  from 		cotillion_admin.entity_configuration config
                                  inner join 	cotillion_admin.sys_entity_types entity_types
                                  on 		config.entity_type_id_fk = entity_types.entity_type_id_pk
                                  inner join 	cotillion_admin.locations locs
                                  on 		config.entity_id_fk = locs.location_id_pk
                                  where 		entity_types.entity_type_name = 'Location'
                                  and 		entity_configuration like '%CARFAX ID\":\"C%';")    
		rescue 
			msgStr = "Processing location failed.  Error: #{$!}"
			@msg.processMsg("error", "severe", msgStr)
		end
		
	end  
	
	def getLocations()
		#connect to db bases on instance variables
		selectLocations()
		
		@dbResults
	end  
	
	def selectVehicles()
		begin
			@dbResults = @dbConnect.select_all("select       vehs.*
                                          from        cotillion_inventory.tbl_vehicles vehs
                                          inner join  cotillion_inventory.inventories invs
                                          on          vehs.inventory_id_fk = invs.inventory_id_pk
                                          where       location_id_fk = #{@dealerlocation}
                                          and         vehicle_status_id_fk = 2
                                          and         vehicle_id_pk not in (
                                          select      vehicle_id_fk
                                          from        cotillion_inventory.carfax_reports carfax
                                          inner join  cotillion_inventory.tbl_vehicles vehs
                                          on          carfax.vehicle_id_fk = vehs.vehicle_id_pk
                                          where       dealer_carfax_id = '#{@carfax}'
                                          and         ifnull(inventory_results,'') <> ''
                                          and         report_expires >= '#{@timestamp}')")  
		rescue 
			msgStr = "Processing location failed.  Error: #{$!}"
			@msg.processMsg("error", "severe", msgStr)
		end
	end  
	
	def getVehicles(locationId, carFaxId, currentTimestamp)
		@dealerlocation = locationId
		@carfax = carFaxId
		@timestamp = currentTimestamp
		
		#connect to db bases on instance variables
		selectVehicles()
		
		@dbResults
	end	
	
	def selectDealerInfo(locationid)
		begin
			@dbResults = @dbConnect.select_all("select 					
				locs.location_id_pk, 
				locs.location_name, 
				entities_contacts.address_one, 
				entities_contacts.address_two,
				entities_contacts.town,
				entities_contacts.state,
				entities_contacts.postal_code,
				cast(concat(entities_contacts.phone_number_area_code, entities_contacts.phone_number_prefix,entities_contacts.phone_number_suffix) as char(10)) as fullphone
				from cotillion_admin.locations locs 						
				left join 	cotillion_crm.crm_entities_contacts entities_contacts	on 	locs.location_id_pk = entities_contacts.entity_id_fk
				where locs.location_id_pk = #{locationid}")  
		rescue 
			msgStr = "Processing dealer failed.  Error: #{$!}"
			@msg.processMsg("error", "severe", msgStr)
		end
	end  
	
	def getDealers()
		selectDealers()
		
		@dbResults
	end	
	
	def insertReports(vehicle_id_fk, dealer_carfax_id, expiration, isOwner) 	  
		begin	
	      # @dbConnect['AutoCommit'] = false	      
	      # Insert New HA reports
	      currentTimestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")
	      
	      @dbConnect.execute("insert into  cotillion_inventory.carfax_reports
	                                      (vehicle_id_fk, dealer_carfax_id, inventory_results, report_run, report_expires, report_type, problem, one_owner)
	                      values          (#{vehicle_id_fk}, '#{dealer_carfax_id}', 'Y', '#{currentTimestamp}', '#{expiration}', 'CIP', 'N', #{isOwner})")
	                      
	      # Commit transaction     
	      @dbConnect.commit
	    rescue
	      # Ohhh, snap!  Something went horribly, horribly wrong...let's get outta here
	      @dbhInv.rollback
		  # handle error  
		msgStr = "Processing insert carfax reports failed.  Error: #{$!}"
		@msg.processMsg("error", "severe", msgStr)

	    ensure
	      @dbConnect['AutoCommit'] = true
	    end

	end  	
	
	def getVehicleIDs(vehicle_serial, location_id_fk)
		begin		
		  @dbResults = @dbConnect.select_all("SELECT vehicle_id_pk 
			FROM cotillion_inventory.tbl_vehicles veh
			join  cotillion_inventory.inventories invs ON invs.inventory_id_pk = veh.inventory_id_fk
			WHERE invs.location_id_fk =  #{location_id_fk}
			AND   veh.vehicle_serial = 	'#{vehicle_serial}' ")  
		rescue
	      # Ohhh, snap!  Something went horribly, horribly wrong...let's get outta here
		  # handle error  
		msgStr = "Could not get vehicle ids.  Error: #{$!} vehicle serial number #{vehicle_serial} location id = #{location_id_fk}"
		@msg.processMsg("error", "severe", msgStr)
		end

	end


	def getHADealerID(location_id_pk)

		begin		

		  @dbResults = @dbConnect.select_all("	select 		entity_configuration
                                  from 		cotillion_admin.entity_configuration config
                                  inner join 	cotillion_admin.sys_entity_types entity_types
                                  on 		config.entity_type_id_fk = entity_types.entity_type_id_pk
                                  inner join 	cotillion_admin.locations locs
                                  on 		config.entity_id_fk = locs.location_id_pk
                                  where 		entity_types.entity_type_name = 'Location' and locs.location_id_pk = #{location_id_pk}
                                  and 		entity_configuration like '%CARFAX ID\":\"C%'';")
		end

	end
	
	def deleteHAReports(vehicle_id_fk) 	  

		begin	
	      currentTimestamp = Time.now.strftime("%Y-%m-%d %H:%M:%S")	      
	      
	      # Delete existing reports for this vehicle id

	      # @dbConnect['AutoCommit'] = false
      		@dbConnect.execute("delete from    cotillion_inventory.carfax_reports
                      where           vehicle_id_fk = #{vehicle_id_fk}")
	                      
	      # Commit transaction     
	      @dbConnect.commit

	    rescue
	      # Ohhh, snap!  Something went horribly, horribly wrong...let's get outta here
	      @dbhInv.rollback
		  # handle error  
		msgStr = "Processing delete carfax reports failed.  Error: #{$!}"
		@msg.processMsg("error", "severe", msgStr)
		  
	    ensure
	      @dbConnect['AutoCommit'] = true
	    end

	end
	


	
end	

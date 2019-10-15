#################
#
# This lists all the triggers we use to 
# create all the objects we need when we create a new organization
# via the Unee-T Enterprise Interface
#
#################

# We create a trigger when a record is added to the `external_persons` table

	DROP TRIGGER IF EXISTS `ut_after_insert_new_organization`;

DELIMITER $$
CREATE TRIGGER `ut_after_insert_new_organization`
AFTER INSERT ON `uneet_enterprise_organizations`
FOR EACH ROW
BEGIN

# We always do this:

	# we get the id of the organization that was just created

		SET @organization_id = NEW.`id_organization` ;

	# We get the role type that we will use:

		SET @default_ut_user_role_type_id_new_organization = NEW.`default_role_type_id` ;

	# The designations for the different role types

		SET @role_type_designation_tenant := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 1
			)
			;

		SET @role_type_designation_landlord := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 2
			)
			;

		SET @role_type_designation_mgt_cny := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 4
			)
			;

		SET @role_type_designation_agent := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = 5
			)
			;

	# What is the default coutry for this organization:

		SET @default_country_code_new_organization = NEW.`country_code` ;

	# What is the name of the new organization

		SET @new_organization_name = NEW.`designation` ;

# First we need to create a new user type for the SuperAdmin for this organization

	INSERT INTO `ut_user_types`(
		`id_unee_t_user_type`
		,`syst_created_datetime`
		,`creation_system_id`
		,`created_by_id`
		,`creation_method`
		,`organization_id`
		,`order`
		,`is_obsolete`
		,`designation`
		,`description`
		,`ut_user_role_type_id`
		, `is_super_admin`
		) 
		VALUES
			(0
			, NOW()
			,'Setup'
			,0
			,'trigger_ut_after_insert_new_organization'
			, @organization_id
			,NULL
			,0
			,'Super Admin'
			,'The main MEFE Unee-T user associated to this UNTE account'
			, @default_ut_user_role_type_id_new_organization
			, 1
			)
		;

	# We capture the ID of this new user type we just created
	
		SET @last_inserted_user_type_id = LAST_INSERT_ID();

# we need to generate an API key for the organization

	INSERT INTO `ut_api_keys`
		(`syst_created_datetime`
		,`creation_system_id`
		,`created_by_id`
		,`creation_method`
		,`is_obsolete`
		,`api_key`
		,`organization_id`
		) 
		VALUES
			(NOW()
			, 'Setup'
			, @organization_id
			,'trigger_ut_after_insert_new_organization'
			, 0
			, UUID()
			, @organization_id
			)
		;

# Add a new record in the table `external_persons` so we can create a MEFE user for that organization.
# This will automatically create a new MEFE user id.

	INSERT INTO `external_persons`
		(`external_id`
		,`external_system`
		,`external_table`
		,`syst_created_datetime`
		,`creation_system_id`
		,`created_by_id`
		,`creation_method`
		,`person_status_id`
		,`is_unee_t_account_needed`
		,`unee_t_user_type_id`
		,`country_code`
		,`given_name`
		,`family_name`
		,`email`
		) 
		VALUES
			# IF YOU CHANGE THE BELOW LINE YOU NEED TO UPDATE THE
			# PHPR EVENT Add Page >> After record added
			# FOR THE PHPR VIEW `Super Admin - Manage Organization`
			(CONCAT (0
				, '-'
				, @organization_id
				)
			# IF YOU CHANGE THE BELOW LINE YOU NEED TO UPDATE THE
			# FOR THE PHPR VIEW 
			#	- `Super Admin - Manage Organization
			#	  PHPR EVENT Add Page >> After record added
			# FOR THE SQL VIEW
			#	- `ut_list_possible_assignees`
			#	  
			, 'Setup'
			# IF YOU CHANGE THE BELOW LINE YOU NEED TO UPDATE THE
			# PHPR EVENT Add Page >> After record added
			# FOR THE PHPR VIEW `Super Admin - Manage Organization
			, 'Setup'
			, NOW()
			, 'Setup'
			, @organization_id
			, 'trigger_ut_after_insert_new_organization'
			, 2
			, 1
			, @last_inserted_user_type_id
			, @default_country_code_new_organization
			, 'Master User MEFE'
			, @new_organization_name
			, CONCAT ('superadmin.unte'
				, '+'
				, @organization_id
				, '@unee-t.com'
				)
			)
		;

# We need to create the default Unee-T user type for this organization:
#		- Tenant (1)
#		- Owner/Landlord (2)
#		- We have NO default user for the user type contractor (3)
#		- management company (4)
#		- Agent (5)	

	INSERT INTO `ut_user_types`
		(`syst_created_datetime`
		,`creation_system_id`
		,`created_by_id`
		,`creation_method`
		,`organization_id`
		,`order`
		,`is_obsolete`
		,`designation`
		,`description`
		,`ut_user_role_type_id`
		,`is_super_admin`
		,`is_public`
		,`is_default_assignee`
		,`is_default_invited`
		, `is_dashboard_access`
		, `can_see_role_mgt_cny`
		, `can_see_occupant`
		, `can_see_role_landlord`
		, `can_see_role_agent`
		, `can_see_role_tenant`
		) 
		VALUES
			# Tenant (1)
			(NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_tenant
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_tenant
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 1
				, 0
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				)
			# Owner/Landlord (2)
			, (NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_landlord
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_landlord
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 2
				, 0
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				) 
			# management company (4)
			, (NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_mgt_cny
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_mgt_cny
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 4
				, 0
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				) 
			# Agent (5)
			, (NOW()
				, 'Setup'
				, @organization_id
				, 'trigger_ut_after_insert_new_organization'
				, @organization_id
				, 0
				, 0
				, CONCAT ('Default Public User - '
					, @role_type_designation_agent
					)
				, CONCAT ('Use this for the public account for the role '
					, @role_type_designation_agent
					, '. This is the user people will report issue to by default'
					)
				# What is the `ut_user_role_type_id`
				#		- Tenant (1)
				#		- Owner/Landlord (2)
				#		- We have NO default user for the user type contractor (3)
				#		- management company (4)
				#		- Agent (5)
				, 5
				, 0
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				, 1
				) 
			;

END;
$$
DELIMITER ;
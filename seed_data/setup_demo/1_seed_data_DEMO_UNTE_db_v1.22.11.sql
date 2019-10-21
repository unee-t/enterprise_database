# This is a seed script to create multiple objects in the UNTE datatabase.
# This will make it easier to have data in the DEMO environment so people can try it out.

# This is Step 1. We are creating the following objects:
#	- Organization
#	- SoT for this organization
#	- Update the default SoT for the organization
#	- Admin user for UNTE for the organization
#	- MEFE Super User for the organization
# 
# The automated routine and scripts will create:
#	- 5 user types:
#		 - SuperAdmin
#		 - Default Public User - Tenant
#		 - Default Public User - Owner/Landlord
#		 - Default Public User - Management Company
#		 - Default Public User - Agent
#	- UNTE API key for the organization
#	- MEFE user ID for the master MEFE user
#	- MEFE API key for the master MEFE user
#	- Default Assignee
#		- Mgt Cny
#		- Landlord
#		- Agent
#		- Tenant
#

# Define the variables that we need:

	SET @demo_cpny_name = 'ACME' ;

	SET @demo_cny_role = 'Property Management' ;

	SET @demo_cny_role_type = 4 ;

	SET @demo_cny_country_code = 'US' ;

	SET @demo_email_prefix = 'demo.email+' ;

	SET @demo_email_suffix = '@unee-t.com' ;

	SET @demo_default_password = 'test_password' ;

# Create the Organization ACME Propperty Management

	INSERT INTO `uneet_enterprise_organizations`
		(`syst_created_datetime`
		, `creation_system_id`
		, `creation_method`
		, `created_by_id`
		, `is_obsolete`
		,`designation`
		,`description`
		,`country_code`
		,`default_role_type_id`
		) 
		VALUES
			(NOW()
			, 0
			, 'Super Admin - Manage Organization'
			, 1
			, 0
			, CONCAT (@demo_cpny_name
				, ' '
				, @demo_cny_role
				)
			, CONCAT ('Demo company'
				, @demo_cny_role
				)
			, @demo_cny_country_code
			, @demo_cny_role_type
			)
		;

# Capture the newly create id for that organization

	SET @new_organization_id = LAST_INSERT_ID() ;

# We insert the data for the SoT for that organization

	SET @sot_system = CONCAT (LOWER(@demo_cpny_name)
			, '_database'
		)
		;

	SET @sot_person = 'person' ;
	SET @sot_area = 'area' ;
	SET @sot_L1P = 'L1P' ;
	SET @sot_L2P = 'L2P' ;
	SET @sot_L3P = 'L3P' ;

	INSERT INTO `ut_external_sot_for_unee_t_objects`
		(`syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `organization_id`
		, `order`
		, `is_obsolete`
		, `designation`
		, `description`
		, `person_table`
		, `area_table`
		, `properties_level_1_table`
		, `properties_level_2_table`
		, `properties_level_3_table`
		) 
		VALUES
			(NOW()
			, 0
			, 1
			, 'Super Admin - Manage Organization'
			, @new_organization_id
			, 0
			, 0
			, @sot_system
			, CONCAT ('The database for '
				, @demo_cpny_name
				)
			,'person'
			,'area'
			,'L1P'
			,'L2P'
			,'L3P'
			)
		;

# We update the default SoT for this organization:

	SET @new_sot_id = LAST_INSERT_ID() ;

	UPDATE `uneet_enterprise_organizations`
		SET `default_sot_id` = @new_sot_id
		WHERE `id_organization` = @new_organization_id
		;

# We create the Admin user for the ACME organization

	SET @admin_username = (CONCAT ('admin.'
			, LOWER(@demo_cpny_name)
			)
		)
		;

	SET @admin_fullname = (CONCAT ('Administrator '
			, @demo_cpny_name
			)
		)
		;
	
	SET @admin_email = (CONCAT (@demo_email_prefix
			, 'admin.'
			, LOWER(@demo_cpny_name)
			, @demo_email_suffix
			)
		)
		;

	INSERT INTO `uneet_enterprise_users`
		(`username`
		, `password`
		, `email`
		, `fullname`
		, `groupid`
		, `active`
		, `organization_id`
		)
		VALUES
			(@admin_username
			, @demo_default_password
			, @admin_email
			, @admin_fullname
			, NULL
			, 1
			, @new_organization_id
			)
			;

# We Assign the administrator to the relevant group

	INSERT INTO `uneet_enterprise_ugmembers`
		(`UserName`
		,`GroupID`
		) 
		VALUES
			(@admin_username
			,1
			)
		;

# We create the default Unee-T users for this company

	# Mgt Cny

		SET @email_default_assignee = (CONCAT (@demo_email_prefix
				, 'support.'
				, LOWER(@demo_cpny_name)
				, @demo_email_suffix
				)
			)
			;

		SET @default_assignee_user_type = (SELECT `id_unee_t_user_type`
			FROM `ut_user_types`
			WHERE `organization_id` = @new_organization_id
				AND `ut_user_role_type_id` = 4
				AND `creation_system_id` = 'Setup'
				AND `is_super_admin` = 0
			)
			;

		INSERT INTO `external_persons`
			(`external_id`
			, `external_system`
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `person_status_id`
			, `is_unee_t_account_needed`
			, `unee_t_user_type_id`
			, `country_code`
			, `gender`
			, `salutation_id`
			, `given_name`
			, `family_name`
			, `alias`
			, `email`
			) 
			VALUES
				(@email_default_assignee
				, @sot_system
				, @sot_person
				, NOW()
				, 'Unee-T Enterprise portal'
				, @new_organization_id
				, 'Manage_Unee_T_Users_Add_Page'
				, 2
				, 1
				, @default_assignee_user_type
				, @demo_cny_country_code
				, 0
				, 1
				, 'Support'
				, @demo_cpny_name
				, 'Help'
				, @email_default_assignee
				)
			;

	# Agent

		SET @email_default_assignee_agent = (CONCAT (@demo_email_prefix
				, 'agent.'
				, LOWER(@demo_cpny_name)
				, @demo_email_suffix
				)
			)
			;

		SET @default_assignee_user_type = (SELECT `id_unee_t_user_type`
			FROM `ut_user_types`
			WHERE `organization_id` = @new_organization_id
				AND `ut_user_role_type_id` = 5
				AND `creation_system_id` = 'Setup'
				AND `is_super_admin` = 0
			)
			;

		INSERT INTO `external_persons`
			(`external_id`
			, `external_system`
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `person_status_id`
			, `is_unee_t_account_needed`
			, `unee_t_user_type_id`
			, `country_code`
			, `gender`
			, `salutation_id`
			, `given_name`
			, `family_name`
			, `alias`
			, `email`
			) 
			VALUES
				(@email_default_assignee_agent
				, @sot_system
				, @sot_person
				, NOW()
				, 'Unee-T Enterprise portal'
				, @new_organization_id
				, 'Manage_Unee_T_Users_Add_Page'
				, 2
				, 1
				, @default_assignee_user_type
				, @demo_cny_country_code
				, 0
				, 1
				, 'Support'
				, @demo_cpny_name
				, 'Help'
				, @email_default_assignee_agent
				)
			;

	# Landlord
	
		SET @email_default_assignee_landlord = (CONCAT (@demo_email_prefix
				, 'landlord.'
				, LOWER(@demo_cpny_name)
				, @demo_email_suffix
				)
			)
			;

		SET @default_assignee_user_type = (SELECT `id_unee_t_user_type`
			FROM `ut_user_types`
			WHERE `organization_id` = @new_organization_id
				AND `ut_user_role_type_id` = 2
				AND `creation_system_id` = 'Setup'
				AND `is_super_admin` = 0
			)
			;

		INSERT INTO `external_persons`
			(`external_id`
			, `external_system`
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `person_status_id`
			, `is_unee_t_account_needed`
			, `unee_t_user_type_id`
			, `country_code`
			, `gender`
			, `salutation_id`
			, `given_name`
			, `family_name`
			, `alias`
			, `email`
			) 
			VALUES
				(@email_default_assignee_landlord
				, @sot_system
				, @sot_person
				, NOW()
				, 'Unee-T Enterprise portal'
				, @new_organization_id
				, 'Manage_Unee_T_Users_Add_Page'
				, 2
				, 1
				, @default_assignee_user_type
				, @demo_cny_country_code
				, 0
				, 1
				, 'Support'
				, @demo_cpny_name
				, 'Help'
				, @email_default_assignee_landlord
				)
			;

	# Tenant

		SET @email_default_assignee_tenant = (CONCAT (@demo_email_prefix
				, 'tenant.'
				, LOWER(@demo_cpny_name)
				, @demo_email_suffix
				)
			)
			;

		SET @default_assignee_user_type = (SELECT `id_unee_t_user_type`
			FROM `ut_user_types`
			WHERE `organization_id` = @new_organization_id
				AND `ut_user_role_type_id` = 1
				AND `creation_system_id` = 'Setup'
				AND `is_super_admin` = 0
			)
			;

		INSERT INTO `external_persons`
			(`external_id`
			, `external_system`
			, `external_table`
			, `syst_created_datetime`
			, `creation_system_id`
			, `created_by_id`
			, `creation_method`
			, `person_status_id`
			, `is_unee_t_account_needed`
			, `unee_t_user_type_id`
			, `country_code`
			, `gender`
			, `salutation_id`
			, `given_name`
			, `family_name`
			, `alias`
			, `email`
			) 
			VALUES
				(@email_default_assignee_tenant
				, @sot_system
				, @sot_person
				, NOW()
				, 'Unee-T Enterprise portal'
				, @new_organization_id
				, 'Manage_Unee_T_Users_Add_Page'
				, 2
				, 1
				, @default_assignee_user_type
				, @demo_cny_country_code
				, 0
				, 1
				, 'Support'
				, @demo_cpny_name
				, 'Help'
				, @email_default_assignee_tenant
				)
			;

# We update the table `uneet_enterprise_organizations` 
# with the infomation about the Master MEFE user for this organization

	SET @external_id_master_mefe_user = (CONCAT (0
			, '-'
			, @new_organization_id
			)
		)
		;

	UPDATE `uneet_enterprise_organizations`
		SET 
			`mefe_master_user_external_person_id` = @external_id_master_mefe_user
			, `mefe_master_user_external_person_table` = 'Setup'
			, `mefe_master_user_external_person_system` = 'Setup'
		WHERE `id_organization` = @new_organization_id
		;
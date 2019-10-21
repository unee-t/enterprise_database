# This is a seed script to create multiple objects in the UNTE datatabase.
# This will make it easier to have data in the DEMO environment so people can try it out.

#####################################################
#
# IMPORTANT INFORMATION:
# To do this step, we need to make sure that MEFE has created the following objects:
#	- MEFE Master USer
#	- Default Assignees for the company
#		- Mgt Cny
#		- Landlord
#		- Agent
#		- Tenant
#
#####################################################


# In the previous Step 1. We have created the following objects:
#	- Organization
#	- SoT for this organization
#	- Update the default SoT for the organization
#	- Admin user for UNTE for the organization
#	- MEFE Super User for the organization
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

# This Step 2 creates the following objects:
#	- Default Area
#	- Default L1P
#	- Default L2P

# We need to know which organization we are dealing with

	SET @organization_id_for_step_2 = 10 ;

# The variables below should be identical as is Step 1
	
	SET @demo_email_prefix = 'demo.email+' ;

	SET @demo_email_suffix = '@unee-t.com' ;

	SET @demo_cny_country_code = 'US' ;

#####################################
#
# We have everything, we can run the script
#
#####################################

# Define the variables that we need:

	SET @demo_cny_name = (SELECT `designation`
		FROM `uneet_enterprise_organizations`
		WHERE `id_organization` = @organization_id_for_step_2
		)
		;

	SET @default_role_type_id =  (SELECT `default_role_type_id`
		FROM `uneet_enterprise_organizations`
		WHERE `id_organization` = @organization_id_for_step_2
		)
		;


	SET @default_sot_id = (SELECT `default_sot_id`
		FROM `uneet_enterprise_organizations`
		WHERE `id_organization` = @organization_id_for_step_2
		)
		;

	SET @default_sot_designation = (SELECT `designation`
		FROM `ut_external_sot_for_unee_t_objects`
		WHERE `id_external_sot_for_unee_t` = @default_sot_id
		)
		;

	# The default tables:

		SET @default_table_person = (SELECT `person_table`
		FROM `ut_external_sot_for_unee_t_objects`
		WHERE `id_external_sot_for_unee_t` = @default_sot_id
		)
		;

		SET @default_table_area = (SELECT `area_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

		SET @default_table_L1P = (SELECT `properties_level_1_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

		SET @default_table_L2P = (SELECT `properties_level_2_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

		SET @default_table_L3P = (SELECT `properties_level_3_table`
			FROM `ut_external_sot_for_unee_t_objects`
			WHERE `id_external_sot_for_unee_t` = @default_sot_id
			)
			;

	# The Master MEFE user for this organization

		SET @mefe_master_user_external_person_id = (SELECT `mefe_master_user_external_person_id`
			FROM `uneet_enterprise_organizations`
			WHERE `id_organization` = @organization_id_for_step_2
			)
			;

		SET @mefe_master_user_external_person_table = 'Setup';

		SET @mefe_master_user_external_person_system = 'Setup';

		SET @mefe_master_user_mefe_id = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_2
				AND `external_person_id` = @mefe_master_user_external_person_id
				AND `table_in_external_system` = @mefe_master_user_external_person_table
				AND `external_system` = @mefe_master_user_external_person_system
			)
			;


	# The MEFE IDs for the default Assignees for this organization

		# Mgt Cny

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'support.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;

			SET @mefe_id_default_mgt_cny = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_2
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
			)
			;
	
			SET @external_person_id = NULL ;

		# Agent

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'agent.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;

			SET @mefe_id_default_agent = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_2
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
				)
				;
	
			SET @external_person_id = NULL ;

		# Landlord

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'landlord.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;

			SET @mefe_id_default_landlord = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_2
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
				)
				;
	
			SET @external_person_id = NULL ;

		# Tenant

			SET @external_person_id = (CONCAT (@demo_email_prefix
					, 'tenant.'
					, LOWER(@demo_cpny_name)
					, @demo_email_suffix
					)
				)
				;
		
			SET @mefe_id_default_tenant = (SELECT `unee_t_mefe_user_id`
			FROM `ut_map_external_source_users`
			WHERE 
				`organization_id` = @organization_id_for_step_2
				AND `external_person_id` = @external_person_id
				AND `table_in_external_system` = @default_table_person
				AND `external_system` = @default_sot_designation
				)
				;
	
			SET @external_person_id = NULL ;

########################################
#
# We have all the variables we need
#
########################################

# Update the Organization record: add the default assignees:

	UPDATE `uneet_enterprise_organizations`
		SET 
			`default_assignee_mgt_cny` = @mefe_id_default_mgt_cny
			, `default_assignee_agent` = @mefe_id_default_agent
			, `default_assignee_landlord` = @mefe_id_default_landlord
			, `default_assignee_tenant` = @mefe_id_default_tenant
		WHERE `id_organization` = @organization_id_for_step_2
		;

# Create the default area for this organization

	SET @create_what = 'area' ;

	SET @default_area_name = (CONCAT('Unknown '
			, @create_what
			, ' - '
			, UPPER(@demo_cny_name)
			)
		)
		;

	SET @default_area_external_id= (CONCAT('unknown_'
			, @create_what
			, '_'
			, LOWER(@demo_cny_name)
			)
		)
		;

	SET @default_area_description = (CONCAT(UPPER(@demo_cny_name)
			, ' - We have no information on the '
			, @create_what
			, ' for these properties.'
			)
		)
		;

	INSERT INTO `external_property_groups_areas`
		(`external_id`
		, `external_system_id`
		, `external_table`
		, `syst_created_datetime`
		, `creation_system_id`
		, `created_by_id`
		, `creation_method`
		, `is_update_on_duplicate_key`
		, `is_creation_needed_in_unee_t`
		, `is_obsolete`
		, `is_default`
		, `order`
		, `country_code`
		, `area_name`
		, `area_definition`
		, `mgt_cny_default_assignee`
		, `agent_default_assignee`
		)
		VALUES
			(@default_area_external_id
			, @default_sot_designation
			, @default_table_area
			, NOW() 
			, @default_sot_id
			, @organization_id_for_step_2
			, 'Manage_Areas_Add_Page'
			, 0
			, 1
			, 0
			, 1
			, 0
			, @demo_cny_country_code
			, @default_area_name
			, @default_area_description
			, @mefe_id_default_mgt_cny
			, @mefe_id_default_agent
			)
		;

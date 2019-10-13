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

	# The designation for the role type

		SET @role_type_designation := (SELECT `role_type`
			FROM `ut_user_role_types`
			WHERE `id_role_type` = @default_ut_user_role_type_id_new_organization
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

	# WIP - We need to record the id of that person so we can access the 
	# MEFE user ID for that person
	# This is a key information to create unee-t objects as this organization


# We need to create a default Unee-T user type for this organization:

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
			(NOW()
			, 'Setup'
			, @organization_id
			, 'trigger_ut_after_insert_new_organization'
			, @organization_id
			, 0
			, 0
			, CONCAT ('Default Public User - '
				, @role_type_designation
				)
			, CONCAT ('Use this for the public account for the role '
				, @role_type_designation
				, '. This is the user people will report issue to by default'
				)
			, @default_ut_user_role_type_id_new_organization
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

# We also need to create a default Area for that organization
# WIP 
# IDEA: This should be done AFTER the first user is created for that orgnanization

	INSERT INTO `external_property_groups_areas`
		(`external_id`
		,`external_system_id`
		,`external_table`
		,`syst_created_datetime`
		,`creation_system_id`
		,`created_by_id`
		,`creation_method`
		,`is_creation_needed_in_unee_t`
		,`is_obsolete`
		,`is_default`
		,`order`
		,`country_code`
		,`area_name`
		,`area_definition`
		) 
		VALUES
			(CONCAT (0
				, '-'
				, @organization_id
				)
			, 'Setup'
			, 'Setup'
			, NOW()
			, 0
			, @organization_id
			, 'trigger_ut_after_insert_new_organization'
			, 1
			, 0
			, 1
			, 0
			, @default_country_code_new_organization
		, 'Default Area'
		, 'The default area for this organization'
		)
		;

END;
$$
DELIMITER ;
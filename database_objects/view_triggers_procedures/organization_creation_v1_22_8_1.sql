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

END;
$$
DELIMITER ;
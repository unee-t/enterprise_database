
# Triggers

	DROP TRIGGER IF EXISTS `ut_create_user`;
	DROP TRIGGER IF EXISTS `ut_create_unit`;
	DROP TRIGGER IF EXISTS `ut_add_user_to_role_in_unit_with_visibility`;
	DROP TRIGGER IF EXISTS `ut_update_unit`;
	DROP TRIGGER IF EXISTS `ut_retry_create_unit`;
	DROP TRIGGER IF EXISTS `ut_retry_assign_user_to_unit`;

# Procedures:

	DROP PROCEDURE IF EXISTS `lambda_create_user`;
	DROP PROCEDURE IF EXISTS `lambda_create_unit`;
	DROP PROCEDURE IF EXISTS `lambda_add_user_to_role_in_unit_with_visibility`;
	DROP PROCEDURE IF EXISTS `ut_update_user`;
	DROP PROCEDURE IF EXISTS `lambda_update_user_profile`;
	DROP PROCEDURE IF EXISTS `lambda_update_unit`;
	DROP PROCEDURE IF EXISTS `ut_remove_user_from_unit`;
	DROP PROCEDURE IF EXISTS `lambda_remove_user_from_unit`;
	DROP PROCEDURE IF EXISTS `lambda_update_unit_name_type`;


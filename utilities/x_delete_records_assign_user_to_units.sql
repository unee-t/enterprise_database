SET @delete_when := '2019-04-27 13:03:27' ;

DELETE FROM `external_map_user_unit_role_permissions_level_1` 
WHERE `syst_created_datetime` = @delete_when
;

DELETE FROM `external_map_user_unit_role_permissions_level_1` 
WHERE `syst_updated_datetime` = @delete_when
;
DELETE FROM `external_map_user_unit_role_permissions_level_2` 
WHERE `syst_created_datetime` = @delete_when
;

DELETE FROM `external_map_user_unit_role_permissions_level_2` 
WHERE `syst_updated_datetime` = @delete_when
;
DELETE FROM `ut_map_user_permissions_unit_level_1` 
WHERE `syst_created_datetime` = @delete_when
;

DELETE FROM `ut_map_user_permissions_unit_level_1` 
WHERE `syst_updated_datetime` = @delete_when
;

DELETE FROM `ut_map_user_permissions_unit_level_2` 
WHERE `syst_created_datetime` = @delete_when
;

DELETE FROM `ut_map_user_permissions_unit_level_2` 
WHERE `syst_updated_datetime` = @delete_when
;

DELETE FROM `ut_map_user_permissions_unit_all` 
WHERE `syst_updated_datetime` = @delete_when
;

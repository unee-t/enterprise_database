THIS RESET THE NAMES TO THE NAMES IN THE MEFE

SELECT
    `a`.`unee_t_mefe_unit_id`
    , `a`.`uneet_name`
    , `b`.`displayName`
    , `a`.`external_property_type_id`
FROM
    `ut_map_external_source_units` AS `a`
    INNER JOIN `unitMetaData_display_names` AS `b`
        ON (`a`.`unee_t_mefe_unit_id` = `b`.`_id`)
WHERE `a`.`uneet_name` != `b`.`displayName`
ORDER BY 
	`a`.`uneet_name` ASC
	, `a`.`external_property_type_id` ASC
;

UPDATE `ut_map_external_source_units` AS `a`
	INNER JOIN `unitMetaData_display_names` AS `b`
		ON (`a`.`unee_t_mefe_unit_id` = `b`.`_id`)
	SET 
		`a`.`uneet_name` = `b`.`displayName`
		, `a`.`is_update_needed` = 1
		, `a`.`syst_updated_datetime` = NOW()
		, `a`.`update_system_id` = 3
		, `a`.`updated_by_id` = 'NXnKGEdEwEvMgWQtG'
		, `a`.`update_method` = 'manual reset'
	WHERE `a`.`uneet_name` != `b`.`displayName`
	;


THIS RESET THE NAMES TO THE NAME IN THE PROD


SELECT
    `a`.`uneet_name`
    , `a`.`id_map`
    , `b`.`id_map`
    , `b`.`uneet_name`
FROM
    `ut_map_external_source_units` AS `a`
    INNER JOIN `old_property_names_in_PROD` AS `b`
        ON (`a`.`id_map` = `b`.`id_map`)
;

UPDATE `ut_map_external_source_units` AS `a`
    INNER JOIN `old_property_names_in_PROD` AS `b`
        ON (`a`.`id_map` = `b`.`id_map`)
	SET `a`.`uneet_name` = `b`.`uneet_name`
		, `a`.`is_update_needed` = 1
		, `a`.`syst_updated_datetime` = NOW()
		, `a`.`update_system_id` = 3
		, `a`.`updated_by_id` = 'NXnKGEdEwEvMgWQtG'
		, `a`.`update_method` = 'manual reset'
	WHERE `a`.`uneet_name` != `b`.`uneet_name`
	;
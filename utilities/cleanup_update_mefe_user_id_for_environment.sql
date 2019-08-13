# This script updates the MEFE user ID to the correct value foa a given environment:
#
# MEFE Creator_id:
#   - DEV/Staging: E4RFHFCQGsXGPcCb5 (hmlet.enterprise.dev@unee-t.com)
#   - PROD: NXnKGEdEwEvMgWQtG (hmlet.enterprise@unee-t.com)
#   - DEMO: hF4AxDx6r6ue2TgFD (hmlet.enterprise.demo@unee-t.com)
#
# BY DEFAULT THIS SCRIPT USES THE MEFE Creator_id FOR THE DEV/STAGING ENVIRONMENT!!!

    SET @mefe_user_id_for_cleanup = 'E4RFHFCQGsXGPcCb5' ;
    SET @organization_id_for_cleanup = 2 ;

    SET @disable_lambda = 1 ;

# Do the update

    UPDATE `ut_api_keys`
        SET 
            `mefe_user_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;
        
    UPDATE `persons`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `persons`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `property_groups_areas`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `property_groups_areas`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `property_level_1_buildings`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `property_level_1_buildings`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `property_level_2_units`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `property_level_2_units`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `property_level_3_rooms`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `property_level_3_rooms`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `ut_map_external_source_units`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `ut_map_external_source_units`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `ut_map_external_source_users`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `ut_map_external_source_users`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `ut_map_user_permissions_unit_all`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `ut_map_user_permissions_unit_all`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `ut_map_user_permissions_unit_level_1`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `ut_map_user_permissions_unit_level_1`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `ut_map_user_permissions_unit_level_2`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `ut_map_user_permissions_unit_level_2`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;
    
    UPDATE `ut_map_user_permissions_unit_level_3`
        SET 
            `created_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
        ;

    UPDATE `ut_map_user_permissions_unit_level_3`
        SET 
            `updated_by_id` = @mefe_user_id_for_cleanup
        WHERE `organization_id` = @organization_id_for_cleanup
            AND `updated_by_id` IS NOT NULL
        ;

# We make sure the lambdas are enabled again


    SET @disable_lambda = 0 ;
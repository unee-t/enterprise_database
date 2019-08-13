# This script uses the view `view_sales_main_contacts_currently_active_flats` to import occupants from IPI to Unee-T
# Key issues:
#	- Create user
#	- Assign user to unit
#	- De-Assign user from unit

# Run this query in hmlet IPI - PROD

	CREATE TABLE `unee_t_export_hmlet_member_list_15May2019`
	AS
	SELECT
		`view_sales_main_contacts_currently_active_flats`.`id_customer`
		, `db_all_dt_2_flats`.`condo_id` AS `hmlet_external_id_building`
		, `db_all_dt_2_flats`.`system_id_flat` AS `hmlet_external_id_flat`
		, `view_sales_main_contacts_currently_active_flats`.`flat_id` AS `hmlet_flat_designation`
		, `db_all_dt_4_customers`.`room_id` AS `hmlet_external_id_room`
		, `view_sales_main_contacts_currently_active_flats`.`room_designation` AS `hmlet_room_designation`
		, `view_sales_main_contacts_currently_active_flats`.`customer_invoice_name` AS `customer_name`
		, `view_sales_main_contacts_currently_active_flats`.`current_date_in`
		, `view_sales_main_contacts_currently_active_flats`.`current_date_out`
		, `view_sales_main_contacts_currently_active_flats`.`first_name`
		, `view_sales_main_contacts_currently_active_flats`.`last_name`
		, `view_sales_main_contacts_currently_active_flats`.`email`
		, `view_sales_main_contacts_currently_active_flats`.`mobile_phone`
	FROM
		`view_sales_main_contacts_currently_active_flats`
		INNER JOIN `db_all_dt_4_customers` 
			ON (`view_sales_main_contacts_currently_active_flats`.`id_customer` = `db_all_dt_4_customers`.`id_customer`)
		INNER JOIN `db_all_dt_2_flats` 
			ON (`db_all_dt_4_customers`.`flat_id` = `db_all_dt_2_flats`.`flat_id`)
	ORDER BY `view_sales_main_contacts_currently_active_flats`.`flat_id` ASC, `view_sales_main_contacts_currently_active_flats`.`room_designation` ASC
	;

# Copy the table you have just generated into the Unee-T Enterprise Database
# DO NOT Delete the table from IPI PROD this can be used for audit purposes
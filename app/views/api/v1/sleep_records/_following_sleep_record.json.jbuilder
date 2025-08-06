json.id sleep_record.id
json.user_name sleep_record.try(:user_name) || sleep_record.user.name
json.clock_in sleep_record.clock_in
json.clock_out sleep_record.clock_out
json.duration_hours sleep_record.duration_in_hours
json.created_at sleep_record.created_at
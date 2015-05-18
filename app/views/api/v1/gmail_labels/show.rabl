object @gmail_label

attributes :label_id, :name
attributes :message_list_visibility, :label_list_visibility
attributes :label_type
attributes :num_threads, :num_unread_threads unless locals[:no_counts]

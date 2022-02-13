package User;

use strict;
use warnings;

use ODS;

name "user";

options (
	icon_mode => true,
	locale_section => 'user_cards',
	remove_empty => true,
	createable => {
		type => "POST",
		endpoint => "/users/create",
		id => "create-user-form"
	},
	editable => {
		type => "POST",
		endpoint => "/users",
		header_field => "username",
		id => "edit-user-form"
	},
	deleteable => {
		type => "DELETE",
		endpoint => "/users",
		header_field => "username",
	},
	fetch_data => { 
		method => "GET",
		endpoint => "/users",
	},
	pagination => {}
);

column id => (
	type => 'integer',
	auto_increment => true,
	required => true,
	sortable => true,
	filterable => true,
	no_render => true
);

column username => (
	type => 'string',
	required => true,
	min_length => 3,
	max_length => 30,
	sortable => { active => true, direction => "desc" },
	filterable => true,
	field => {
		attributes => {
			required => true,
		},
		editable => {
			attributes => {
				readonly => true
			}
		}
	}
);

column first_name => (
	sortable => true,
	filterable => true,
	field => {
		attributes => {
			required => true,
		}
	}
);

column last_name => (
	sortable => true,
	filterable => true,
	field => {
		attributes => {
			required => true,
		}
	}
);

column email => (
	type => 'string',
	validate => 'email',
	required => true,
	sortable => true,
	filterable => true,
	field => {
		type => "email",
		attributes => {
			required => true
		}
	}	
);

column admin => (
	type => 'boolean',
	sortable => true,
	filterable => true,
	field => {
		type => "switch"
	}
);

column active => (
	type => 'boolean',
	sortable => true,
	filterable => true,
	field => {
		type => "switch"
	}
);

column mobile => (
	type => 'string',
	validate => "phone",
	filterable => true
);

column landline => (
	type => 'string',
	valiate => "phone",
	filterable => true
);

column address_line_1 => (
	filterable => true
);

column address_line_2 => (
	filterable => true
);

column address_line_3 => (
	filterable => true
);

column address_line_4 => (
	filterable => true
);

# all dates will be stored in epoch, format conversion will only happen if requested
# else it will be the UI/Clients responsibility moment(time).format(...).
column last_login => (
	format => "YYYY-MM-DD hh:mm:ss",
	sortable => true,
	filterable => true,
	field => {
		type => "none"
	}
);

column last_action => (
	format => "YYYY-MM-DD hh:mm:ss",
	sortable => true,
	filterable => true,
	field => {
		type => "none"
	}
);

__END__

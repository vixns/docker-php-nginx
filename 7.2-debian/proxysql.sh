#!/bin/sh
exec 2>&1

if [ ! -e /etc/proxysql/proxysql.cnf ]
then
	OLDIFS=IFS
	IFS=","
	servers=""
	for s in ${MYSQL_SERVERS}
	do
		mysql_host=$(echo $s |cut -d':' -f1)
		mysql_port=$(echo $s |cut -d':' -f2)
		servers = "${servers}{address=\"${mysql_host}\" , port=${mysql_port}, hostgroup=2, max_latency_ms=100, max_replication_lag=100 },"
	done

	users=""
	for u in ${MYSQL_USERS}
	do
		user_name=$(echo $s |cut -d':' -f1)
		user_pass=$(echo $s |cut -d':' -f2)
		users = "${users}{username = "${user_name}", password = \"${user_pass}\"},"
	done

	rules=""
	rule_id=0
	for u in ${PROXYSQL_RULES}
	do
		rule_id=$(expr $rule_id + 1)
		rule_digest=$(echo $s |cut -d':' -f1)
		rule_ttl=$(echo $s |cut -d':' -f2)
		rule_comment=$(echo $s |cut -d':' -f3)
		rules = "${rules}{rule_id=${rule_id},active=1,match_digest=\"${rule_digest}\",cache_ttl=${rule_ttl}000,comment=\"${rule_comment}\"},"
	done

	#	{
	#		rule_id=1
	#		active=1
	#		match_pattern="^SELECT .* FOR UPDATE$"
	#		destination_hostgroup=0
	#		apply=1
	#	},
	IFS=$OLDIFS

	cat > /etc/proxysql/proxysql.cnf << EOF
datadir="/var/lib/proxysql"
admin_variables=
{
	admin_credentials="admin:admin;${PROXYSQL_ADMIN_USER}:${PROXYSQL_ADMIN_PASS}"
	stats_credentials="${PROXYSQL_STATS_USER}:${PROXYSQl_STATS_PASS}"
	mysql_ifaces="0.0.0.0:6032"
	web_enabled=true
	web_port=6080

}
mysql_variables=
{
	threads=4
	max_connections=2048
	max_allowed_packet=134217728
	default_query_delay=0
	default_query_timeout=36000000
	have_compress=true
	poll_timeout=2000
	interfaces="0.0.0.0:6033"
	default_schema="information_schema"
	stacksize=1048576
	server_version="5.6.40"
	connect_timeout_server=3000
	monitor_username="${PROXYSQL_MONITOR_USER}"
	monitor_password="${PROXYSQL_MONITOR_PASS}"
	monitor_history=600000
	monitor_connect_interval=60000
	monitor_ping_interval=10000
	monitor_read_only_interval=1500
	monitor_read_only_timeout=500
	ping_interval_server_msec=120000
	ping_timeout_server=500
	commands_stats=true
	sessions_sort=true
	connect_retries_on_failure=10
	wait_timeout=000
}

mysql_servers=
(
${servers%,}
)

mysql_users=
(
${users%,}
)

mysql_query_rules=
(
${rules%,}
)

mysql_group_replication_hostgroups=
(
        {
                writer_hostgroup=0,
                backup_writer_hostgroup=1,
                reader_hostgroup=2,
                offline_hostgroup=3,
                max_transactions_behind=100
       }
)

EOF
fi

exec proxysql -c /etc/proxysql/proxysql.cnf -D /var/lib/proxysql -f -e

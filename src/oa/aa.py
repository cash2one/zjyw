# coding: utf8
from zjyw_utils import *
import datetime
with myapi.connection() as con:
    cur = con.cursor()
#    s='set names utf8'
#    cur.execute( s )
#    sql = "insert into AgentWarn ( warn_detail, warn_level, warn_suggest, warn_isclose, warn_time_join, warn_type, warn_agent, warn_task )values('烦烦烦','5','sss收拾收拾','1','www','1','www','www')"
#    print( "阿瑟大时代======%s"%sql )
#    sql_id = "select * from AgentTask where task_id='10001'"
#    cur.execute(sql_id)
#    rs = myapi.sql_execute(cur, sql_id)
#    ls=[]
#    while rs.next():
#        rs_lst = rs.to_dict()
#        ls.append(rs_lst)
#    print( "=========%s"%repr(ls) )
    """
    结果集：
        [{'task_start_time': '20160625011010', 'task_time_join': '20160621102320', 'task_type': '1', 'task_module': '1', 'task_id': '10001', 'task_day': None, 'task_scheme_time': '2016-04-06 20:33:20', 'task_real_time': '2016-07-26 06:36:47', 'task_group': '1', 'task_agent': '10000001', 'task_time': '16:06:00', 'task_result': '\xe6\x9c\x89\xe4\xbd\x93\xe6\xa3\x80\xe9\xa1\xb9\xe6\x9c\xaa\xe9\x80\x9a\xe8\xbf\x87\xe5\xb9\xb6\xe4\xb8\x94\xe6\x9c\x89\xe4\xbd\x93\xe6\xa3\x80\xe9\xa1\xb9\xe6\x9c\xaa\xe6\xa0\xb8\xe6\x9f\xa5', 'task_circle': '1', 'task_state': '1', 'task_user_join': 'zjyw', 'task_name': '\xe5\x9f\xba\xe4\xba\x8e\xe5\xb7\xa5\xe4\xbf\xa1\xe9\x83\xa8\xe5\x9f\xba\xe7\xba\xbf\xe7\x9a\x84\xe4\xbd\x93\xe6\xa3\x80\xe4\xbb\xbb\xe5\x8a\xa1', 'task_detail': '\xe6\xa3\x80\xe6\xb5\x8b\xe4\xb8\xbb\xe6\x9c\xba', 'task_week': '3'}]
    """
#    sql_id = "select * from AgentTask"
#    cur.execute(sql_id)
#    rs = cur.fetchone()
#    print( "=========%s"%repr(rs) )
    """
    结果集：   
        ('10001', '\xe5\x9f\xba\xe4\xba\x8e\xe5\xb7\xa5\xe4\xbf\xa1\xe9\x83\xa8\xe5\x9f\xba\xe7\xba\xbf\xe7\x9a\x84\xe4\xbd\x93\xe6\xa3\x80\xe4\xbb\xbb\xe5\x8a\xa1', '\xe6\xa3\x80\xe6\xb5\x8b\xe4\xb8\xbb\xe6\x9c\xba', '1', '16:06:00', '3', None, '1', '10000001', '1', 'zjyw', '20160621102320', '1', '1', '\xe6\x9c\x89\xe4\xbd\x93\xe6\xa3\x80\xe9\xa1\xb9\xe6\x9c\xaa\xe9\x80\x9a\xe8\xbf\x87\xe5\xb9\xb6\xe4\xb8\x94\xe6\x9c\x89\xe4\xbd\x93\xe6\xa3\x80\xe9\xa1\xb9\xe6\x9c\xaa\xe6\xa0\xb8\xe6\x9f\xa5', '2016-07-26 06:36:47', '20160625011010', '2016-04-06 20:33:20')
    """
    sql_id = "select * from AgentTask"
    cur.execute(sql_id)
    rs = cur.fetchall()
    print( "=========%s"%repr(rs) )
#    task_id = datetime.datetime.now().strftime("%Y%m%d")+str(int(rs[0][0]))
#    print( "=========%s"%task_id )
# coding: utf8
import json
import datetime
from django.conf import settings
import MySQLdb as db2api

#import hashlib
#def check_id(mw, encrypt_str ):
#    # 校验主机id
#    encrypt_str1 = hashlib.md5(str(mw) ).hexdigest().upper()
#    if encrypt_str == encrypt_str1:
#        return True  # 验证成功
#    else:
#        return False  # 验证失败

import __builtin__
import inspect
class Namespace:
    # 用于提供注册到系统中扩展函数的名字空间
    @staticmethod
    def create( name ):
        if not name:
            __builtin__.ns_modules = {}
            return __builtin__
        
        root = __builtin__
        path = []
        for x in name.split('.'):
            path.append( x )
            if hasattr( root , x ):
                root = getattr( root , x )
            else:
                ns = Namespace( '.'.join( path ) )
                setattr( root , x , ns )
                root = ns
                
        return root
        
    def __init__( self , name ):
        self.__name = name
        self.ns_modules = {}
    
    def __str__( self ):
        return self.__name

def _register( spc , obj ):
    if inspect.isfunction( obj ):
        name = getattr( obj , 'name' , obj.func_name )
    elif inspect.isclass( obj ):
        name = obj.__name__
    else:
        raise RuntimeError( '名字空间中只可注册函数或类[%s]' % str( type( obj ) ) )
        
    if name in spc.ns_modules and obj.__module__ != spc.ns_modules[ name ]:
        warnings.warn( '已经在[%s]名字空间中注册了函数[%s]' % ( spc , name ) , RuntimeWarning )
        #raise RuntimeError( '已经在[%s]名字空间中注册了函数[%s]' % ( spc , name ) )
        return
    
    spc.ns_modules[ name ] = obj.__module__
    setattr( spc , name , obj )

def register( namespace = None ):
    if type( namespace ) in ( tuple , list ):
        ns = map( Namespace.create , namespace )
    else:
        ns = ( Namespace.create( namespace ) , )
    
    def _reg( func ):
#        # TODO 此处的注释很奇怪, 貌似是为了规避什么问题. 但历史太过久远. 暂时封闭下面代码, 有问题再打开
#        if func.__module__ == '__main__':
#            return func
            
        for n in ns:
            _register( n , func )
        return func
        
    return _reg

class DBConnection( object ):
    def __init__( self , constr = None ):
        if constr is None:
            self.con = db2api.connect( **settings.DB_CONSTR )
        else:
            self.con = db2api.connect( **constr )
        self.cursors = []
    
    def cursor( self ):
        cursor = self.con.cursor()
        cursor.execute( "set names utf8" )
        self.cursors.append( cursor )
        
        return cursor
    
    def has_table( self , tname , schema = None ):
        cur = self.cursor()
        if schema is None:
            cur.execute("""select relname from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname=current_schema() and lower(relname)=%(name)s""", {'name':tname.lower() } );
        else:
            cur.execute("""select relname from pg_class c join pg_namespace n on n.oid=c.relnamespace where n.nspname=%(schema)s and lower(relname)=%(name)s""", {'name':tname.lower() , 'schema':schema});
        return bool( cur.rowcount )
    
    def execute( self , sql , params = None ):
        cur = self.cursor()
        kind = sql.strip()[:6].lower()
        if type( params ) in ( tuple , list ):
            if len( params ) and type( params[0] ) in ( tuple , list , dict ):
                cur.executemany( sql , params )
                return cur
            if kind != 'select':
                cur.execute( sql , params )
                return cur
        elif type( params ) in ( dict , ):
            if kind != 'select':
                cur.execute( sql , params )
                return cur
        else:
            if kind!='select':
                cur.execute( sql )
                return cur
        # 剩下的全是查询
        return myapi.sql_execute( cur , sql , params )
        
    def begin( self ):
        pass
    
    def rollback( self ):
        self.con.rollback()
        self.close()
        # 抛异常后，应清理数据库连接，避免该线程下的数据库操作一直异常
        self.con = db2api.connect( **settings.DB_CONSTR )
    
    def commit( self ):
        self.con.commit()
        self.close()
    
    def close( self ):
        map( lambda x:x.close() , self.cursors )
        self.cursors = []

@register( 'myapi' )
def connect( constr = None ):
    return DBConnection( constr )

from contextlib import contextmanager
@register( 'myapi' )
@contextmanager
def connection( constr = None ):
    """
    用在with语句中，用于提供数据库连接对象。线程安全
    用法：
        with connection() as con:
            cur = con.cursor()
            cur.execute( "select * from gl_jddy where mc = '银联'" )
            rs = cur.fetchone() 
            ...
    """
    con = None
    try:
        con = DBConnection( constr )
        yield con
        con.commit()
    except:
        if con:
            con.rollback()
        raise
    finally:
        if con:
            con.close()

@register( 'myapi' )
def sql_execute( cur , sql , params = None , encoding = 'utf8' ):
    return ResultSet( cur , sql , params , encoding )

class ResultSet( object ):
    """ 
        将cur的select返回结果转换为可按字段名称访问的格式
    """
    def __init__( self , cur , sql , params = None , encoding = 'utf8' ):
        """
            @param:cur   数据库引擎
            @param:sql   sql语句  变量用%s或%d的形式代替  例如:select * from gl_hydy where hydm ='%s' and jgdm =%d
            @param:params   参数列表(数据类型为列表),sql语句所需要的参数顺序组成的列表,接上面的例子,参数列表为: ['admin' , 10 ]
            @param:encoding  编码形式
        """
        self.__cursor = cur
        self.fields = {}
        #self.rowno  = 0
        self.encoding = encoding
        if params:
            self.__cursor.execute( sql , params )
        else:
            self.__cursor.execute( sql )
        if self.__cursor.description == None:
            return
        for i in range( 0 , len( self.__cursor.description ) ):
            self.fields[ self.__cursor.description[i][0].lower() ] = i
        self.row_cache = []

    @property
    def rowcount( self ):
        """
            返回sql结果记录条数
        """
        return self.__cursor.rowcount
    
    def printFieldName( self ):
        """
            打印查询结果各字段的字段名
        """
        for i in self.fields.keys():
            print i ,
    
    def next( self ):
        """
            顺序取下一条记录，直到取尽
        """
        #self.rowno += 1
        if not self.row_cache:
            self.row_cache = self.__cursor.fetchmany( 100 )
        self.row_cache = list(self.row_cache) if self.row_cache else None
        print( self.row_cache )
        self.item = self.row_cache.pop( 0 ) if self.row_cache else None
        return self if self.item != None else None
    
    fetchone = next
    
    def __iter__( self ):
        while self.next():
            yield self
    
    def fetchall( self ):
        """
            取所有数据
        """
        rows = []
        while self.next():
            rows.append( self.to_dict())
            #rows.append(  AttrDict(  self.to_dict( )  )  )
        return rows
    
    def getString( self , key , encoding = 'utf8' ):
        """
            以字符串形式返回某个字段的值
                @param:key  字段名称
                @encoding:  编码形式
        """
        if isinstance( key , int ):
            v = self.item[ key ]
        else:
            idx = self.fields[ key.lower() ]
            v = self.item[ idx ]
        if type( v ) == unicode:
            return v.encode( encoding )
        elif type( v ) == str and self.encoding != encoding :
            return v.decode( self.encoding ).encode( encoding )
        elif v:
            return str( v )
        elif v is not None:
            return str(v)
        else:
            return v
    
    def getUnicode( self , key ):
        """
            获取字段key的unicode值
            @param:key 字段名称
        """
        if isinstance( key , int ):
            v = self.item[ key ]
        else:
            idx = self.fields[ key.lower() ]
            v = self.item[ idx ]
        if type( v ) == str:
            return v.decode( self.encoding )
        elif v:
            return unicode( v )
        else:
            return v
    
    def getInt( self , key ):
        """
            以整数形式返回字段key的值
            @param: key 字段名称
        """
        if isinstance( key , int ):
            v = self.item[ key ]
        else:
            idx = self.fields[ key.lower() ]
            v = self.item[ idx ]
        if v:
            return int( v )
        else:
            return 0
    
    def getDouble( self , key ):
        """
            以float型返回字段key的值
            @param:key 字段名称
        """
        if isinstance( key , int ):
            v = self.item[ key ]
        else:
            idx = self.fields[ key.lower() ]
            v = self.item[ idx ]
        if v:
            return float( v )
        else:
            return 0.0
    
    def getValue( self , key ):
        """
            获取某个字段的值，是什么类型就返回什么类型
        """
        if isinstance( key , int ):
            v = self.item[ key ]
        else:
            idx = self.fields[ key.lower() ]
            v = self.item[ idx ]
        return v
    
    def getDate( self , key ):
        """
            获取日期型字段的值
        """
        if isinstance( key , int ):
            v = self.item[ key ]
        else:
            idx = self.fields[ key.lower() ]
            v = self.item[ idx ]
        if type( v ) == datetime.datetime:
            v = v.date()
        elif v and type( v ) != datetime.date:
            raise RuntimeError( '非日期字段不可按日期获取数据' )
        return v
    
    def getPickle( self , key ):
        if isinstance( key , int ):
            v = self.item[ key ]
        else:
            idx = self.fields[ key.lower() ]
            v = self.item[idx]
        if type( v ) == buffer:
            return pickle_loads( v )
        else:
            return None
    
    def to_dict( self ):
        """
            将查询结果转化成字典的形式，键为字段名，实际值
        """
        d = {}
        for key , i in self.fields.items():
            d[ key ] = self.item[ i ]
        return d
    
    def __getitem__( self , key ):
        """
            获取某个字段的值
        """
        return self.getValue( key )
    
    def __getattr__( self , key ):
        return self.getValue( key )
        
    def close( self ):
        try:
            self.__cursor.close()
        except:
            pass
    
    def mkInsert( self , tn ):
        """
            按照查询出来的结果，拼写插入语句
        """
        s = 'insert into ' + tn + '('
        a = self.fields.keys()
        s += ','.join( a ) 
        s += ') values ('
        vs = []
        for k in a:
            v = self.getValue( k )
            if type( v ) == type(''):
                vs.append( "'%s'" % v )
            elif type( v ) == type(0) :
                vs.append( "%d" % v )
            elif type( v ) == type(0.1):
                vs.append( "%f" % v )
            elif v == None:
                vs.append( "null" )
            else:
                vs.append( "to_date( '%s' , 'YYYYMMDD' )" % v.strftime( '%Y%m%d' ) )
        s += ','.join( vs )
        s += ')'
        return s
        

class FakeResultSet( ResultSet ):
    """ result的替换对象
    """
    def __init__( self , cur , sql ):
        self.fields = {}
        self.item = []
        self.first = True
    
    def next( self ):
        if self.first :
            self.first = False
            return True
        return False


#if __name__ == "__main__":
#    # 查询本地账户信息
#    sql = "select * from auth_user "
#    with connection() as con:
#        cur = con.cursor()
#        rs = sql_execute(cur, sql)
##        rs = rs.fetchall()
##        print repr(rs)
#        while rs.next():
#            rs_lst = rs.to_dict()
#            print repr(rs_lst)

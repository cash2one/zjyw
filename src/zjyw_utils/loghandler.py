# -*- coding: utf8 -*-

import logging

import time

class DateFileHandler(logging.FileHandler):
    def __init__(self, filename, mode="a" ):
        self.bf = filename
        self.curDate = time.strftime( '%Y%m%d' , time.localtime())
        self.mode = mode
        t = time.time()
        filename = filename + '.' + self.curDate
        logging.FileHandler.__init__(self, filename, mode)

    def emit(self, record):
        cd = time.strftime( '%Y%m%d' , time.localtime())
        if cd != self.curDate:
            self.stream.close()
            self.curDate = cd
            self.stream = open(self.bf + '.' + cd , self.mode )
        logging.FileHandler.emit(self, record)

class DatabaseHandler( logging.Handler ):
    def __init__( self , cur , prefix ):
        """
            @param cur 数据库操作句柄
            @param prefix 日志标题格式为yyyy-mm-dd[xx项目]后台数据处理
        """
        logging.Handler.__init__( self )
        self.cur = cur 
        self.prefix = prefix
        self.fmtsql = """insert into gl_xtczrz( hydm , fssj , jb , btxx , xxxx ) 
values ( 'back' , sysdate , %%d , '%s' , '%%s' )""" %  prefix
        
    def emit( self , record ):
        sql = self.fmtsql % ( record.levelno / 10 , record.message )
        if self.cur:
            self.cur.execute( sql )
    
    def filter( self , record ):
        if record.levelno > logging.INFO:
            return True
        return False
    
    def close( self ):
        self.cur.close()
        self.cur = None
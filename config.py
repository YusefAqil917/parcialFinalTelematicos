class Config:
    MYSQL_HOST = 'localhost'
    MYSQL_USER = 'root'
    MYSQL_PASSWORD = 'root'
    MYSQL_DB = 'myflaskapp'
   
    SQLALCHEMY_DATABASE_URI = "mysql+mysqldb://root:root@mysql_db:3306/myflaskapp"  # Docker
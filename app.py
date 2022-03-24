from flask import Flask, render_template, request
from flask_sqlalchemy import SQLAlchemy
from send_email import send_email
from sqlalchemy.sql import func

app=Flask(__name__)
#app.config below contains POSTGRES username/pwd MUST CHANGE!!!!
app.config['SQLALCHEMY_DATABASE_URI']='postgresql://postgres:POSTGRESPASSWORD@localhost/height_collector'
db=SQLAlchemy(app)

class Data(db.Model):
    __tablename__="data" #creating the table
    id=db.Column(db.Integer, primary_key=True) #creating the columns
    email_=db.Column(db.String(120), unique=True)
    height_=db.Column(db.Integer)

    def __init__(self,email_,height_):
        self.email_=email_
        self.height_=height_

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/success", methods=['POST'])
def success():
    if request.method=='POST':
        email=request.form["email_name"]
        height=request.form["height_name"]
        print(email,height)
        if db.session.query(Data).filter(Data.email_==email).count() == 0:
            data=Data(email,height)
            db.session.add(data) #adding values to db
            db.session.commit() #commits changes to db
            average_height=db.session.query(func.avg(Data.height_)).scalar()
            average_height=round(average_height,1)
            print(average_height)
            count=db.session.query(Data.height_).count()
            send_email(email, height, average_height, count)
            return render_template("success.html")
    return render_template('index.html',
    text="Your email address has already been used.")

if __name__ == '__main__':
    app.debug=True
    app.run()


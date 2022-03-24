import smtplib
#from email.mime.text import MIMEText #For HTML emails
# from email.mime.text import MIMEMultipart

def send_email(email,height,average_height, count): # CHANGE EMAIL AND PASSWORD!!!
    from_email = "YOUREMAIL@EMAIL.com"
    from_password = "YOURPASSWORD"
    to_email=email

    subject="Height Data"
    message="Subject: Your results are here! \n\n Hello! Your height is %s.  The average for everyone who submitted is %s. So far %s people have submitted their data." % (height, average_height,count)

   # msg=MIMEText(message,'html')
   # msg['Subject']=subject
    # msg['To']=to_email
    # msg['From']=from_email

    gmail=smtplib.SMTP('smtp.gmail.com',587)
    gmail.ehlo()
    gmail.starttls()
    gmail.login(from_email, from_password)
    gmail.sendmail(from_email, to_email, message)
    gmail.close()

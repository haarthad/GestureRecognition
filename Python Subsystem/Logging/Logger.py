import datetime


class Logger:

    def __init__(self, name):
        time = datetime.datetime.now().strftime("_%H_%M_%S")
        self.name = name + time
        self.f = open(self.name, "w")

    def log(self, logdata):
        self.f.write(logdata)

    def closelog(self):
        self.f.close()
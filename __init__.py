import datetime
import time
import tailer
import json
from mycroft import MycroftSkill, intent_file_handler

class DisplayLogs(MycroftSkill):
    def __init__(self):
        super().__init__(self.__class__.__name__)
        self.selected_log = None

    def initialize(self):
        self.log.info("Loaded DisplayLogs Skill")
        self.gui.register_handler("logger.skill.refresh.log", self.handle_refresh_logs)
        self.gui.register_handler("logger.skill.select.log", self.handle_select_log)
        self.gui.register_handler("logger.skill.close.logs", self.handle_close_logs)
        self.gui.register_handler("logger.skill.enable.auto.refresh",
                                  self.handle_enable_auto_refresh)
        self.gui.register_handler("logger.skill.disable.auto.refresh",
                                  self.handle_disable_auto_refresh)
        self.selected_log = "bus"

    def handle_enable_auto_refresh(self, message):
        now = datetime.datetime.now()
        callback_time = datetime.datetime(
            now.year, now.month, now.day, now.hour, now.minute
        ) + datetime.timedelta(seconds=60)
        self.schedule_repeating_event(self.handle_display_log,
                                      callback_time, 10)

    def handle_disable_auto_refresh(self, message):
        self.cancel_all_repeating_events()

    def handle_close_logs(self, message):
        self.gui.remove_page("DisplayLogs.qml")
        self.gui.release()

    def handle_refresh_logs(self, message):
        log_to_refresh = message.data.get("log", "")
        self.selected_log = log_to_refresh
        self.handle_display_log()

    def handle_select_log(self, message):
        select_new_log = message.data.get("selected", "")
        self.selected_log = select_new_log
        self.handle_display_log()

    def get_log(self):
        if self.selected_log == "skills":
            return "/var/log/mycroft/skills.log"
        if self.selected_log == "bus":
            return "/var/log/mycroft/bus.log"
        if self.selected_log == "audio":
            return "/var/log/mycroft/audio.log"
        if self.selected_log == "voice":
            return "/var/log/mycroft/voice.log"
        if self.selected_log == "enclosure":
            return "/var/log/mycroft/enclosure.log"

    @intent_file_handler("display_mycroft_log.intent")
    def handle_display_voice_intent(self, message):
        logtype = message.data.get("logtype", "")
        acceptedtype = ["skills", "bus", "audio", "voice", "enclosure"]
        if logtype in acceptedtype:
            self.selected_log = logtype
            self.handle_display_log()

    def handle_display_log(self):
        results = []
        lines = tailer.tail(open(self.get_log()), 50)
        for line in lines:
            try:
                r = line.split('|')
                result = {"timestamp": r[0],
                          "type": r[1],
                          "intentid": r[2],
                          "intent": r[3],
                          "content": r[4]}
                results.append(result)
            except:
                result = {"timestamp": "0",
                          "type": "TRACEBACK",
                          "intentid": "Unknown",
                          "intent": "Unknown",
                          "content": line}
                results.append(result)
                pass
        self.gui["currentLog"] = self.selected_log
        self.gui["skills_log_model"] = {"logs": results}
        self.gui.show_page("DisplayLogs.qml", override_idle=240)

def create_skill():
    return DisplayLogs()



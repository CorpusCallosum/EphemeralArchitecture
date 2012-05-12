/*
SIMPLE TIMER CLASS
Jack Kalish
*/

class Timer {

  long _startTime;
  long _time;
  boolean _expired, _stopped;


  Timer(long t) {
    _time = t*1000; //convert from seconds to ms
    reset();
  }

  float getElapsedTime() {
    return millis() - _startTime;
  }

  void update() {
    if (!_stopped) {
      if (getElapsedTime() > _time) {
        _expired = true;
      }
    }
  }

  boolean isExpired() {
    return _expired;
  }

  void reset() {
    _startTime = millis();
    _expired = false;
    _stopped = true;
  }

  void stop() {
    reset();
  }
  
  void start() {
    _startTime = millis();
    _stopped = false;
  }
}


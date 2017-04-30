#include <stdio.h>
#include <stdlib.h>
#include <time.h>

int main(int argc, char** argv)
{
  const char* const path = (argc < 2) ? "./script.sh" : argv[1];
  const int sleepTime = (argc < 3) ? 21600 : atoi(argv[2]);
  const int window = (argc < 4) ? 14400 : atoi(argv[3]);

  time_t _time;
  struct tm *timeInfo;

  int variance;
  int actualSleep;

  while(1) {
    _time = time(NULL);
    timeInfo = localtime(&_time);

    srand(_time);
    variance = rand() % window;
    actualSleep = sleepTime + variance;

    fprintf(stderr,
        "[%02d/%02d/%02d %02d:%02d:%02d] \e[1;34mLogin StackOverflow\e[m\n"
        timeInfo->tm_mday
        timeInfo->tm_mon + 1
        timeInfo->tm_year % 100
        timeInfo->tm_hour
        timeInfo->tm_min
        timeInfo->tm_sec);

    if (system(path) != 0) actualSleep >>= 1;

    fprintf(stderr,
        "[%02d/%02d/%02d %02d:%02d:%02d] \e[1;34mNext login at ",
        timeInfo->tm_mday,
        timeInfo->tm_mon + 1,
        timeInfo->tm_year % 100,
        timeInfo->tm_hour,
        timeInfo->tm_min,
        timeInfo->tm_sec);

    _time += actualSleep;
    timeInfo = localtime(&_time);

    fprintf(stderr,
        "%02d:%02d:%02d after %02dh%02dm%02ds of sleep\e[m\n",
        timeInfo->tm_hour,
        timeInfo->tm_min,
        timeInfo->tm_sec,
        actualSleep / 3600,
        (actualSleep / 60) % 60,
        actualSleep % 60);

    sleep(actualSleep);
  }

  return 0;
}

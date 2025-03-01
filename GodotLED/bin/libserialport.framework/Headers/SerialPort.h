#ifndef SERIALPORT_H
#define SERIALPORT_H

#include <termios.h>

typedef struct SerialPort
{
	int fileDescriptor;
	struct termios originalAttributes;
} SerialPort;

SerialPort* newSerialPort(char* device, int baud);
void deleteSerialPort(SerialPort* serialPort);
int spIsReadAvailable(SerialPort* serialPort);
int spRead(SerialPort* serialPort);
void spWrite(SerialPort* serialPort, int character);

#endif

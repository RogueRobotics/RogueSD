
// This example lists all the files on the card.

#include <NewSoftSerial.h>
#include <RogueSD.h>

NewSoftSerial roguesd_serial(6, 7);

RogueSD roguesd(roguesd_serial);

void setup()
{
  // This buffer is used to store the filenames from readdir() below
  char filename[64];
  // Number of files and folders in the root folder
  int32_t filecount;

  // Just a simple wait to allow for any unforseen fiddlybits.
  delay(1000);
  
  pinMode(13, OUTPUT);

  Serial.begin(9600);
  
  // Prepare the serial port connected to the Rogue SD module.
  roguesd_serial.begin(9600);

  Serial.println(Constant("Initializing Rogue SD Module..."));

  // sync() prepares the communications with the SD module and closes all open files (if any)
  if (!roguesd.sync(false))
  {
    Serial.println(Constant("Failed initialization. Check baud rate settings."));
    return;
  }

  Serial.print(Constant("Rogue SD Module type: "));
  switch (roguesd.getModuleType())
  {
    case uMMC:
      Serial.println(Constant("uMMC"));
      break;
    case uMP3:
      Serial.println(Constant("uMP3"));
      break;
    case rMP3:
      Serial.println(Constant("rMP3"));
      break;
  }

  Serial.print(Constant("Rogue SD Module Version: "));
  Serial.println(roguesd.version());

  if (roguesd.status())
  {
    // list all files

    // fileCount() takes 2 arguments:
    // 1. source path
    // 2. file mask (e.g. list only MP3 files: "*.mp3")
    // (note: the "/""*" is there because of a problem with the Arduino IDE
    // thinking that /* is the start of a comment
    filecount = roguesd.fileCount("/""*");

    if (filecount >= 0)
    {
      Serial.print(Constant("File count: "));
      Serial.println(filecount, DEC);

      Serial.println("--- Files ---");

      // openDir() opens the directory for reading.
      // argument is the path
      roguesd.openDir("/");

      // readDir() gets the next directory entry that matches the mask. 2 arguments:
      // 1. char buffer to store the name - make sure that it's big enough to store the
      //    largest name in the directory.
      // 2. file mask (same as in filecount())
    
      int type;
    
      while ((type = roguesd.readDir(filename, "*")) > 0)
      {
        if (type == TYPE_FOLDER)  // if it's a folder/directory
          Serial.print(Constant("*DIR* "));
        Serial.println(filename);
      }

      Serial.println("-------------");
    }
    else
    {
      // fileCount() failed, because no card was inserted, or something else.
      Serial.print(Constant("Rogue SD module fileCount failed: Error Code E"));
      if (roguesd.LastErrorCode < 16)
        Serial.print('0');
      Serial.println(roguesd.LastErrorCode, HEX);
    }
  }
  else
  {
    Serial.print(Constant("Rogue SD module sync failed: "));
    if (roguesd.LastErrorCode == ERROR_CARD_NOT_INSERTED)
    {
      Serial.println(Constant("No card inserted."));
    }
    else
    {
      Serial.println(Constant("Error code E"));
      if (roguesd.LastErrorCode < 16)
        Serial.print('0');
      Serial.println(roguesd.LastErrorCode, HEX);
    }
  }
}


void loop()
{
}

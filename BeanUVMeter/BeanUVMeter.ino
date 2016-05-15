//pin setup
#define UVOUT A0
#define EN 3

uint32_t scanInterval = 60000;

void setup()
{
  pinMode(UVOUT, INPUT);
  pinMode(EN, OUTPUT);
  digitalWrite(EN, LOW);
  Bean.setScratchNumber(1, scanInterval); //set default amount of time to wait between checking for new UV data
  Bean.setScratchNumber(3, 0); //just incase there is some invalid data in this bin we want to reset on boot
}

void loop()
{
  uint32_t ujcm2 = Bean.readScratchNumber(3);
  uint32_t uwcm2 = 0;
  
  //wake up UV chip
  digitalWrite(EN, HIGH);

  //make sure chip has enough time to get first reading
  delay(100);

  //read 10 times and take average to reduce variance
  long adcValue = 0;
  for (int x = 0; x < 10; x++)
  {
    adcValue += analogRead(UVOUT);
  }
  adcValue = adcValue/10;

  //put UV chip on standby
  digitalWrite(EN, LOW);

  uwcm2 = (Bean.getBatteryVoltage() * adcValue) / 1023L;
  //right now we have voltage so we want to check the lower bounds first to get rid of noise when indoors
  if (uwcm2 < 100)
  {
    uwcm2 = 0;
  }
  else
  {
    uwcm2 = ((uwcm2 - 100) * 1000) / 12;
  }

  ujcm2 = ujcm2 + (uwcm2 * (scanInterval/1000));
  //set scratchpad #2 to current mwcm2 value
  Bean.setScratchNumber(2,uwcm2);

  //set scratchpad #3 to current mjcm2 value
  Bean.setScratchNumber(3,ujcm2);

  //wait till next interval
  scanInterval = Bean.readScratchNumber(1);
  if (scanInterval < 1000)
    scanInterval = 1000;
  Bean.sleep(scanInterval);
}


#include "asoc.h"

#define BIT_CHECK(a,b) ((a) & (1<<(b)))

#define NEWDATA              2

#define READBYTE          0xc7  //0b11000111
#define SENSORSPISETTING  0x09  //0b00001001
#define EEPROMSPISETTING1 0x03  //0b00000010
#define EEPROMSPISETTING2 0x01  //0b00000001
#define EEPROMWRITEINSTR  0x02 
#define PERIOD_MS           20
#define CLOCKPERIOD_US       1 
#define EEPROM_SIZE       4096      

uint16_t flip16(uint16_t word)
{
	return ((word & 0x00FF) << 8) | ((word & 0xFF00) >> 8);
}

void write_to_eeprom(uint16_t data[4], uint16_t address)
{
	uint8_t i;
	spi_settings(EEPROMSPISETTING1);
	spi_write((EEPROMWRITEINSTR << 16) | address);
	spi_settings(EEPROMSPISETTING2);
	for(i=0;i<4;i++)
	{
		spi_write(data[i]);
	}
	spi_clear();
}

void _start()
{
	const uint32_t PERIOD_CLKS = (1000 * CLOCKPERIOD_US) * PERIOD_MS;
	uint64_t clks;
	uint16_t sensor_status, eeprom_addr;
	uint16_t sensor_data[4];
	uint8_t  i;

	eeprom_addr = 0;
	while(1)
	{
		clks = rdcycles();
		spi_settings(SENSORSPISETTING);
		spi_write(READBYTE);
		sensor_status = spi_read();
		if(BIT_CHECK(sensor_status,NEWDATA))
		{
			for(i=0;i<4;i++)
			{
				spi_write(0);
				sensor_data[i] = flip16(spi_read());
			}
			spi_clear();
			eeprom_addr = (eeprom_addr + 1) % EEPROM_SIZE;
			write_to_eeprom(sensor_data, eeprom_addr);
		}
		spi_clear();
		sleep(PERIOD_CLKS - (rdcycles() - clks));
	}


}
#include "hal_uart.h"

#ifdef __GNUC__
// With GCC/RAISONANCE, small printf (option LD Linker->Libraries->Small printf set to 'Yes') calls __io_putchar()
#define PUTCHAR_PROTOTYPE int __io_putchar(int ch)
#else
#define PUTCHAR_PROTOTYPE int fputc(int ch, FILE *f)
#endif /* __GNUC__ */

void RCC_Configuration(void)
{
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA | RCC_APB2Periph_AFIO,ENABLE);
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_USART1,ENABLE);
}

void UART_GPIO_Configuration(void)
{
	GPIO_InitTypeDef GPIO_InitStruct;

	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_AF_PP;
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_9;
	GPIO_InitStruct.GPIO_Speed = GPIO_Speed_50MHz;

	GPIO_Init(GPIOA, &GPIO_InitStruct);

	GPIO_InitStruct.GPIO_Mode = GPIO_Mode_IN_FLOATING;
	GPIO_InitStruct.GPIO_Pin = GPIO_Pin_10;
	
	GPIO_Init(GPIOA, &GPIO_InitStruct);
}

void UART_Configuration(void)
{
	USART_InitTypeDef USART_InitStruct;

	RCC_Configuration();

	USART_InitStruct.USART_BaudRate = 9600;
	USART_InitStruct.USART_StopBits = USART_StopBits_1;
	USART_InitStruct.USART_WordLength = USART_WordLength_8b;
	USART_InitStruct.USART_Parity = USART_Parity_No;
	USART_InitStruct.USART_HardwareFlowControl = USART_HardwareFlowControl_None;
	USART_InitStruct.USART_Mode = USART_Mode_Tx | USART_Mode_Rx;
	
	USART_Init(USART1, &USART_InitStruct);
	USART_ITConfig(USART1,USART_IT_RXNE,ENABLE);
	USART_Cmd(USART1, ENABLE);
	UART_GPIO_Configuration();
	NVIC_Configuration();
}

//����ʸ���жϣ�ʸ������˼������˳�����Ⱥ����˼��
void NVIC_Configuration(void)
{
  NVIC_InitTypeDef NVIC_InitStructure;											//�������ݽṹ��
  
  NVIC_SetVectorTable(NVIC_VectTab_FLASH, 0x0000);					//���ж�ʸ���ŵ�Flash��0��ַ

  NVIC_PriorityGroupConfig(NVIC_PriorityGroup_1);						//�������ȼ����õ�ģʽ���������Ķ�ԭ�����е�����

  //ʹ�ܴ����жϣ����������ȼ�
  NVIC_InitStructure.NVIC_IRQChannel = USART1_IRQn;
  NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelSubPriority = 0;
  NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;  
  NVIC_Init(&NVIC_InitStructure);														//���ṹ�嶪�����ú�������д�뵽��Ӧ�Ĵ�����
}

void UART1_Send_DATA(uint8_t data)
{
		USART_SendData(USART1,data);
	
		//Loop until the end of transmission
		while (USART_GetFlagStatus(USART1, USART_FLAG_TXE) == RESET);
}

//��ʹ�ð�����ģʽ, ���û����Σ�����Ҫ��targetѡ����ѡ��ʹ��USE microLIB
#if 1 
#pragma import(__use_no_semihosting)
struct __FILE  
{  
	int handle;  
};  
FILE __stdout;  

_sys_exit(int x)  
{  
	x = x;  
}
#endif

PUTCHAR_PROTOTYPE
{
	//Place your implementation of fputc here , e.g. write a character to the USART
	USART_SendData(USART1,(u8)ch);

	//Loop until the end of transmission
	while (USART_GetFlagStatus(USART1, USART_FLAG_TXE) == RESET);

	return ch;
}

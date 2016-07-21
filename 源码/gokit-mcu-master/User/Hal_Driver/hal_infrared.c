#include "hal_infrared.h"

#define IR_EXTI




#ifdef IR_EXTI

void IR_GPIO_Init(void)
{
GPIO_InitTypeDef   GPIO_InitStructure;  
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);  //����IO ʱ��   
  
	/* Configure PA.00 pin as input floating */   
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12;     //����IOģʽ   
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;    //����Ҫ����
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;	
	GPIO_Init(GPIOA, &GPIO_InitStructure);     

}

void IR_EXTI_Init(void)
{
  EXTI_InitTypeDef   EXTI_InitStructure;  
	NVIC_InitTypeDef   NVIC_InitStructure; 
	
  /* Connect EXTI0 Line to PA.00 pin */    
	GPIO_EXTILineConfig(GPIO_PortSourceGPIOA, GPIO_PinSource12); //�趨�����ж��ߡ�
	

	EXTI_ClearITPendingBit(EXTI_Line12);       //�����·����λ  
/* Configure EXTI0 line */    
	EXTI_InitStructure.EXTI_Line = EXTI_Line12;     //�����ж�����   
	EXTI_InitStructure.EXTI_Mode = EXTI_Mode_Interrupt;    
	EXTI_InitStructure.EXTI_Trigger = EXTI_Trigger_Rising_Falling;    //�����ش���   
	EXTI_InitStructure.EXTI_LineCmd = ENABLE;   
	EXTI_Init(&EXTI_InitStructure); 
	
	
	/* Enable and set EXTI0 Interrupt to the lowest priority */   
	NVIC_InitStructure.NVIC_IRQChannel = EXTI15_10_IRQn;      //�����ж����ȼ�    
	NVIC_InitStructure.NVIC_IRQChannelPreemptionPriority = 1;   
	NVIC_InitStructure.NVIC_IRQChannelSubPriority = 2;   
	NVIC_InitStructure.NVIC_IRQChannelCmd = ENABLE;   
	NVIC_Init(&NVIC_InitStructure);
	
}



void IR_Init(void)
{
	IR_GPIO_Init();
	IR_EXTI_Init();

}

//EXTI15_10_IRQHandler
#else

void IR_GPIO_Init(void)
{
GPIO_InitTypeDef   GPIO_InitStructure;  
	RCC_APB2PeriphClockCmd(RCC_APB2Periph_GPIOA, ENABLE);  //����IO ʱ��   
  
	/* Configure PA.00 pin as input floating */   
	GPIO_InitStructure.GPIO_Pin = GPIO_Pin_12;     //����IOģʽ   
	GPIO_InitStructure.GPIO_Mode = GPIO_Mode_IN_FLOATING;    //����Ҫ����
	GPIO_InitStructure.GPIO_Speed = GPIO_Speed_50MHz;	
	GPIO_Init(GPIOA, &GPIO_InitStructure);     
	/* Enable AFIO clock */    
//	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);  //����AFIOʱ��

}
#endif


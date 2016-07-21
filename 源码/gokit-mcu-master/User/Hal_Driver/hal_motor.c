#include "hal_motor.h"
#include "hal_uart.h"

void SA_TIMER_Init(TIM_TypeDef* TIMx, uint16_t TIM_Prescaler, uint16_t TIM_CounterMode,
					uint16_t TIM_Period, uint16_t TIM_ClockDivision)
{
    TIM_TimeBaseInitTypeDef  TIM_TimeBaseStructure;


	TIM_TimeBaseStructure.TIM_Prescaler 		=	TIM_Prescaler; 		//����������ΪTIMxʱ��Ƶ�ʳ�����Ԥ��Ƶֵ
	TIM_TimeBaseStructure.TIM_CounterMode 		= 	TIM_CounterMode;  	//����ģʽ
	TIM_TimeBaseStructure.TIM_Period 			= 	TIM_Period; 		//��������һ�������¼�װ�����Զ���װ�ؼĴ������ڵ�ֵ		
	TIM_TimeBaseStructure.TIM_ClockDivision 	= 	TIM_ClockDivision; 	//����ʱ�ӷָ�:TDTS = Tck_tim
		
	if (TIMx == TIM1 || TIMx == TIM8)
	{
		TIM_TimeBaseStructure.TIM_RepetitionCounter = 0; 	
	}

	TIM_TimeBaseInit(TIMx, &TIM_TimeBaseStructure); //����ָ���Ĳ�����ʼ��TIMx��ʱ�������λ
}

void SA_TIMER_PWM_Init(TIM_TypeDef* TIMx, uint8_t NUM)
{
	TIM_OCInitTypeDef  TIM_OCInitStructure;
	 
	TIM_OCInitStructure.TIM_OCMode 				= TIM_OCMode_PWM2; 			//ѡ��ʱ��ģʽ:TIM�����ȵ���ģʽ2
 	TIM_OCInitStructure.TIM_OutputState 		= TIM_OutputState_Enable; 	//�Ƚ����ʹ��
	TIM_OCInitStructure.TIM_OCPolarity 			= TIM_OCPolarity_Low; 		//�������:TIM����Ƚϼ��Ը�
											  //TIM_OCPolarity_High		 
	if (1 == NUM)
	{	
		TIM_OC1Init(TIMx, &TIM_OCInitStructure);  								
		TIM_OC1PreloadConfig(TIMx, TIM_OCPreload_Enable);  						
	}
	else if(2 == NUM)
	{
		TIM_OC2Init(TIMx, &TIM_OCInitStructure);  								//����Tָ���Ĳ�����ʼ������TIM3 OC2
		TIM_OC2PreloadConfig(TIMx, TIM_OCPreload_Enable);  						//ʹ��TIMx��CCR2�ϵ�Ԥװ�ؼĴ���
	}
	else if(3 == NUM)
	{
		TIM_OC3Init(TIMx, &TIM_OCInitStructure);  								//����Tָ���Ĳ�����ʼ������TIM3 OC2
		TIM_OC3PreloadConfig(TIMx, TIM_OCPreload_Enable);  						//ʹ��TIMx��CCR2�ϵ�Ԥװ�ؼĴ���
	}
	else
	{
		if (4 == NUM)
		{
			TIM_OC4Init(TIMx, &TIM_OCInitStructure);  								//����Tָ���Ĳ�����ʼ������TIM3 OC2
			TIM_OC4PreloadConfig(TIMx, TIM_OCPreload_Enable);  						//ʹ��TIMx��CCR2�ϵ�Ԥװ�ؼĴ���
		}
	}
}

//PWM��ʼ�� 
//PWM�����ʼ��
//arr���Զ���װֵ
//psc��ʱ��Ԥ��Ƶ��

void SA_TIMER_PWMOUT_Init(TIM_TypeDef* TIMx, u16 arr,u16 psc, uint8_t NUM)
{ 	
	if (TIMx == TIM2)
	{
		TIM_DeInit(TIM5);  	//����TIM2��TIM5����IO�ڣ�ͬʱֻ�ܳ�ʼ��һ����ʱ������һ����ʱ���븴λ
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM2, ENABLE);
		SA_GPIO_Init(GPIOA, GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3, GPIO_Mode_AF_PP, GPIO_Speed_50MHz);
	}
	else if (TIMx == TIM3)
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM3, ENABLE);
		SA_GPIO_Init(GPIOA, GPIO_Pin_6 | GPIO_Pin_7, GPIO_Mode_AF_PP, GPIO_Speed_50MHz);		//����ص�IO�� ʹ�ø����������
		SA_GPIO_Init(GPIOB, GPIO_Pin_0 | GPIO_Pin_1, GPIO_Mode_AF_PP, GPIO_Speed_50MHz);		//����ص�IO�� ʹ�ø����������
	}
	else if (TIMx == TIM4)
	{
		RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM4, ENABLE);
		SA_GPIO_Init(GPIOB, GPIO_Pin_6 | GPIO_Pin_7 | GPIO_Pin_8 | GPIO_Pin_9, GPIO_Mode_AF_PP, GPIO_Speed_50MHz);
	}
	else
	{
		if (TIMx == TIM5)
		{
			TIM_DeInit(TIM2);  //����TIM2��TIM5����IO�ڣ�ͬʱֻ�ܳ�ʼ��һ����ʱ������һ����ʱ���븴λ
			RCC_APB1PeriphClockCmd(RCC_APB1Periph_TIM5, ENABLE);
			SA_GPIO_Init(GPIOA, GPIO_Pin_0 | GPIO_Pin_1 | GPIO_Pin_2 | GPIO_Pin_3, GPIO_Mode_AF_PP, GPIO_Speed_50MHz);
		}
	}
	
//	RCC_APB2PeriphClockCmd(RCC_APB2Periph_AFIO, ENABLE);  					//���ʹ�ö˿���ӳ�� �����Ӧ��ʱ��
//	GPIO_PinRemapConfig(GPIO_PartialRemap_TIM3, ENABLE); 					//�˿ڲ�����ӳ��    
// 	SA_GPIO_Init(GPIOB, GPIO_Pin_5, GPIO_Mode_AF_PP, GPIO_Speed_50MHz);		//����ص�IO�� ʹ�ø����������

	SA_TIMER_Init(TIMx, psc, TIM_CounterMode_Up, arr, TIM_CKD_DIV1);	

 	SA_TIMER_PWM_Init(TIMx, NUM);

	TIM_Cmd(TIMx, ENABLE);  //ʹ��
	

}


void Motor_Init(void)
{
		SA_GPIO_Init(GPIOB, GPIO_Pin_8, GPIO_Mode_Out_PP, GPIO_Speed_50MHz); 
//		SA_GPIO_Init(GPIOB, GPIO_Pin_1, GPIO_Mode_Out_PP, GPIO_Speed_50MHz); 
//		SA_GPIO_Init(GPIOB, GPIO_Pin_0, GPIO_Mode_Out_PP, GPIO_Speed_50MHz); 
		SA_GPIO_Init(GPIOB, GPIO_Pin_9, GPIO_Mode_Out_PP, GPIO_Speed_50MHz); 
	
		MOT1 = MOT2 = 0;
	
//		SA_TIMER_PWMOUT_Init(TIM3, MOTOR_ARR , 0, 3);
//		SA_TIMER_PWMOUT_Init(TIM3, MOTOR_ARR , 0, 4);	
		SA_TIMER_PWMOUT_Init(TIM4, MOTOR_ARR , 0, 3);
		SA_TIMER_PWMOUT_Init(TIM4, MOTOR_ARR , 0, 4);	
	
}


void Motor_Control(u8 m1,u8 m2)
{
	u16 temp = (MOTOR_ARR+1) / MOTOR_MAX;
	
// 	if(m1 > MOTOR_MAX)
// 		m1 = MOTOR_MAX;
// 	
// 	if(m2 > MOTOR_MAX)
// 		m2 = MOTOR_MAX;
	
	TIM_SetCompare3(TIM4,m1*temp);	//m1
	TIM_SetCompare4(TIM4,m2*temp);	//m4
	
}

void Motor_status(uint8_t status)
{	
	
	u16 temp = (MOTOR_ARR+1) / MOTOR_MAX;
	
	if(status > MOTOR_MAX)
		status = MOTOR_MAX;
	

	if(status < MOTOR_MAX1)
		status = MOTOR_MAX1;
	
	if(status == 5)
	{
		Motor_Control(0,0);
	}
	else if (status > 5)
	{
		Motor_Control(status*10,0);
	}
	else if (status < 5)
	{
		Motor_Control(0,(10-status)*10);
	}

	
// 	switch (status)
// 	{
// 	case Motor_stop:
// 		GPIO_ResetBits(GPIOB,GPIO_Pin_8);
// 		GPIO_ResetBits(GPIOB,GPIO_Pin_9);
// 	break;
// 	case Motor_Forward:
// 		GPIO_SetBits(GPIOB,GPIO_Pin_8);
// 		GPIO_ResetBits(GPIOB,GPIO_Pin_9);
// 		break;

// 	case Motor_Reverse:
// 		GPIO_SetBits(GPIOB,GPIO_Pin_9);
// 		GPIO_ResetBits(GPIOB,GPIO_Pin_8);
// 		break;	

// 	default :
// 		break;
// 	}

}

//��ʱ��4�жϷ������
void TIM4_IRQHandler(void)   //TIM4�ж�
{
	
	if (TIM_GetITStatus(TIM4, TIM_IT_Update) != RESET)  //���TIM4�����жϷ������
	{
		TIM_ClearITPendingBit(TIM4, TIM_IT_Update  );  //���TIM4�����жϱ�־ 
// 		printf("about:4\r\n");
	}

}



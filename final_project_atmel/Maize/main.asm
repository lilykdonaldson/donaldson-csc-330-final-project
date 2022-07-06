;Lily Donaldson
;12 December 2018
;CSC-Final Project
;A sprite based off of Tamagotchi. Uses a potentiometer to select "eat" or "love". "Eat" feeds the sprite clovers, and "Love" makes the sprite's eyes flash with hearts. Written for use with a piezo.

.def  workhorse = r23
.def adc_value_low = r24
.def adc_value_high =  r25
.def button = r22
.def flag   =r30
 
.macro set_pointer 
  ldi @0, low (@2<<1)
  ldi @1, high (@2<<1)
.endmacro
.cseg 
;ADC interrupt
.org   0x0000         ; reset vector 
    rjmp  setup 
.org     0x002A
      rjmp ISR_ADC     ; jump over interrupt vectors
.org   0x0100  
      
setup: 
    ser   workhorse   
    out   DDRD, workhorse 
    ldi   workhorse, 0b00000000
    out   TCCR0A, workhorse   
    ldi   workhorse, 0b00000100 
    out   TCCR0B, workhorse 
  ;initialize clear, set pointer, refresh
 rcall OLED_initialize    
 set_pointer XL, XH, pixel_array
 ;set up Potentiometer
 ldi     workhorse,0b11101111      
 sts     ADCSRA,workhorse
 ;global interrupts
 sei
 
loop:
 ;draw sprite
 rcall draw_sprite
  ;draw clover
   set_pointer ZL, ZH, Char_005
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 0
 ldi r19, 40
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;rcall OLED_refresh_screen
   set_pointer XL, XH, pixel_array
    ;draw love
  ; rcall GFX_clear_array
   set_pointer ZL, ZH, Char_003
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 30
 ldi r19, 40
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   rcall OLED_refresh_screen
   set_pointer XL, XH, pixel_array
   ;sets up draw arrow
   set_pointer ZL, ZH, Char_024
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
   
   ;move x
    ldi     workhorse, 0b01000010   ; use ADC2
    sts     ADMUX, workhorse 
 cpi adc_value_low,1
    brge preloop2second
 rjmp loop2
;FUNCTIONS -------------------------------------------------------------------------------------------------
wait_t0_overflow: 
  ldi flag,1
    in   button,TIFR0
    andi button,0b00000001              
    cpi  button,0b00000001   
    brne loop
    ldi  workhorse, 0b00000000
    out  TIFR0,workhorse      
    ret
loop2:
  ;pointer
 mov r18, adc_value_low
 ldi r19, 60
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
  ; rcall OLED_refresh_screen
   set_pointer XL, XH, pixel_array
   ldi workhorse,40
   rjmp eat
preloop2second:
 cpi adc_value_low,35
 brlo preloop2second2
 rjmp loop
preloop2second2:
 cpi adc_value_low,25
 brge loop2second
 rjmp loop
loop2second:
   ;pointer
 mov r18, adc_value_low
 ldi r19, 60
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
  ; rcall OLED_refresh_screen
   set_pointer XL, XH, pixel_array
   ldi workhorse,200
   rjmp love

loop3:
  ;pointer
 mov r18, adc_value_low
 ldi r19, 60
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   rcall OLED_refresh_screen
   set_pointer XL, XH, pixel_array
   rjmp loop
eat:
    sbi   PIND, 1      
    out         TCNT0, workhorse
   set_pointer ZL, ZH, Char_005
   rcall GFX_set_shape
      ;heart1
   set_pointer XL, XH, pixel_array
    ldi r18, 38
 ldi r19, 20
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;heart2
   set_pointer XL, XH, pixel_array
    ldi r18, 46
 ldi r19, 28
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;heart3
   set_pointer XL, XH, pixel_array
    ldi r18, 54
 ldi r19, 36
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;mouth move
   ;mouth left
    set_pointer ZL, ZH, Char_223
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 80
 ldi r19, 36
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
 ;mouth right
    set_pointer XL, XH, pixel_array
    ldi r18, 88
 ldi r19, 36
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;maintenance
   dec workhorse 
   rcall OLED_refresh_screen
   cpi workhorse,20
   brlo outofreach
   rjmp eat
love:
    sbi   PIND, 1      
    out         TCNT0, workhorse
   set_pointer ZL, ZH, Char_003
   rcall GFX_set_shape
   ;heart1
   set_pointer XL, XH, pixel_array
    ldi r18, 38
 ldi r19, 20
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;heart2
   set_pointer XL, XH, pixel_array
    ldi r18, 46
 ldi r19, 28
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;heart3
   set_pointer XL, XH, pixel_array
    ldi r18, 54
 ldi r19, 36
   ;move x,y
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;heart eyes
   ;eye1
   set_pointer XL, XH, pixel_array
    ldi r18, 80
 ldi r19, 28
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
 ;eye2
   set_pointer XL, XH, pixel_array
    ldi r18, 88
    ldi r19, 28
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ;maintenance
   dec workhorse 
   rcall OLED_refresh_screen
   cpi workhorse,20
   brlo outofreach
   rjmp love
outofreach:
    rjmp loop
ISR_ADC:
  ;Potentiometer Reading Ready
  in workhorse, SREG
  lds adc_value_low, ADCL
  lds adc_value_high, ADCH 
  lsl  adc_value_high
  lsl  adc_value_high
  lsl  adc_value_high
  lsl  adc_value_high
  lsl  adc_value_high
  lsl  adc_value_high
  lsr adc_value_low
  lsr adc_value_low
  or adc_value_low, adc_value_high
  out SREG, workhorse
  reti
first:
 ldi adc_value_low,30
 rjmp loop2
second:
 ldi adc_value_low,60
 rjmp loop3
draw_sprite:
;A1
 rcall GFX_clear_array
 set_pointer ZL, ZH, Char_187
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 72
 ldi r19, 12
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;D12
 set_pointer ZL, ZH, Char_201
   rcall GFX_set_shape
    ldi r18, 96
 ldi r19, 12
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;A2
   set_pointer ZL, ZH, Char_195
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 72
 ldi r19, 20
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;B2
   set_pointer ZL, ZH, Char_196
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 80
    ldi r19, 20
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;C2
   set_pointer XL, XH, pixel_array
    ldi r18, 88
 ldi r19, 20
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;D2
   set_pointer ZL, ZH, Char_180
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 96
 ldi r19, 20
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;A3
    set_pointer ZL, ZH, Char_179
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 72
 ldi r19, 28
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;A4
   set_pointer XL, XH, pixel_array
    ldi r18, 72
 ldi r19, 28
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;D4
   set_pointer XL, XH, pixel_array
    ldi r18, 96
 ldi r19, 28
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;A5
     set_pointer ZL, ZH, Char_192
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 72
 ldi r19, 36
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;B5
 set_pointer ZL, ZH, Char_223
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 80
 ldi r19, 44
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;C5
   set_pointer XL, XH, pixel_array
    ldi r18, 88
 ldi r19, 44
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;D5
 set_pointer ZL, ZH, Char_217
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 96
 ldi r19, 36
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;A6
 set_pointer ZL, ZH, Char_196
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 72
 ldi r19, 52
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;D6
   set_pointer XL, XH, pixel_array
    ldi r18, 96
 ldi r19, 52
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;B6
 set_pointer ZL, ZH, Char_219
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 80
 ldi r19, 52
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;C6
   set_pointer XL, XH, pixel_array
    ldi r18, 88
 ldi r19, 52
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;B7
 set_pointer ZL, ZH, Char_188
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 80
 ldi r19, 60
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;C7
 set_pointer ZL, ZH, Char_200
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 88
 ldi r19, 60
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;eyes
;B3
 set_pointer ZL, ZH, Char_015
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 80
 ldi r19, 28
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;C3
   set_pointer XL, XH, pixel_array
    ldi r18, 88
 ldi r19, 28
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;mouth
;B4
 set_pointer ZL, ZH, Char_192
   rcall GFX_set_shape
   set_pointer XL, XH, pixel_array
    ldi r18, 80
 ldi r19, 36
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
;C4
    set_pointer ZL, ZH, Char_217
    rcall GFX_set_shape
    set_pointer XL, XH, pixel_array
    ldi r18, 88
   ldi r19, 36
   rcall GFX_set_array_pos
   rcall GFX_draw_shape
   set_pointer XL, XH, pixel_array
   ret
.include  "lib_delay.asm"
.include  "lib_SSD1306_OLED.asm"
.include  "lib_GFX.asm"
.include  "character_map.asm"
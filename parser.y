/********************************************************
 * analizador_sintactico.y
 ********************************************************/
%{
#include <stdlib.h>
#include <iostream>
#include <stdio.h>
#include <string.h>
#include <map>
#include <cstdlib> //-- I need this for atoi

#define NUM_FUN_DEF 14
#define NUM_PAR_DEF 5
using namespace std;

//-- Lexer prototype required by bison, aka getNextToken()
int yylex(); 
int yyerror(const char *p) { cerr << "Error!" << endl; }
void print_cabeceras(void);
void print_funciones(void);
void print_main(char* f);
int imprime (char* f);
int add_fun(char* f);
void printf_add_var(void);
int no_existe_var(char * v);
int buscar_funcion(char *funcion_entrada);
int encuentracero(char *s);
enum enum_parametros {_ti=0,_tf=1,_dt=2,_entradas=3,_salidas=4};
char *n_parametros[]={"ti","tf","dt","entrada(s)","salida(s)"};
float val_parametros[NUM_PAR_DEF]={0.0,10.0,0.01,1,1};
float val_ciniciales[NUM_FUN_DEF]={0};

char* funciones_definidas[]={"cos","sin","tan","acos","asin","atan","cosh","sinh","tanh","exp","frexp","ldexp","log","log10","pow","sqrt","ceil","fabs"};
char op_n[5]="_n";
char op_ng[5]="_ng";
char op_s[5]="_s";
char op_r[5]="_r";
char op_m[5]="_m";
char op_d[5]="_d";
char n_var[100][7];
char n_fun[100][7];
char def_fun[100][200];
int nvari=0,nfuni=0,npari=0,ncinii=0;
int cero;
%}

//-- SYMBOL SEMANTIC VALUES -----------------------------
%union {
  char val[1024];
  char var[10];
  char sym;
};
%token <val> NUM
%token <val> VAR DEQQ AOUTPUT AINPUT 
%token <val> STRINI NDINI INITALC
%token <val> STRPAR TI TF DT NINPUT NOUTPUT  IN_SCALE OUT_SCALE INPUT_ID OUTPUT_ID
%token <sym> OPA OPA1 STOP STRT  
%token <sym> EQL MORE OFNT CFNT
%type  <val> ffun exp res vvar modelo deq parametros ini expp ciniciales condiciones exppc
%left OPA
%left OPA1
%right OFNT






//-- GRAMMAR RULES ---------------------------------------
%%
/*
run:	modelo run 
        | parametros run
        | modelo    
        | parametros    

 */

run:	
        | modelo                    {   
                                        //IMPIMRE ADVERTENCIA DE PARAMETROS POR DEFAUL 
                                        printf("\nWarnning: Se definieron todos los parametros por default\n\n"); 
                                        for(int i=0;i<NUM_PAR_DEF-2;i++)
                                            printf("%s=%0.2f ",n_parametros[i],val_parametros[i]); 
                                         for(int i=NUM_PAR_DEF-2;i<NUM_PAR_DEF;i++)
                                            printf("%s=%d ",n_parametros[i],(int)val_parametros[i]); 
                                        printf("\n");
                                        //FIN IMPIMRE ADVERTENCIA DE PARAMETROS POR DEFAUL 
                                        
                                        // IMPIMRE ADVERTENCIA DE CONDICIONES INCIALES POR DEFAUL 
                                         printf("\nWarnning: Se definieron todos las C.I por default\n\n"); 
                                    }
                                    
        | modelo ciniciales         {   
                                        //IMPIMIR ADVERTENCIA DE PARAMETROS POR DEFAULT    
                                        printf("\nWarnning: Se definieron todos los parametros por default\n\n"); 

                                    }
        
        | parametros modelo         {   
                                        // IMPIMRE ADVERTENCIA DE CONDICIONES INCIALES POR DEFAULT
                                        printf("\nWarnning: Se definieron todos las C.I por default\n\n"); 
                                    }
        | ciniciales             {   
                                        // IMPIMRE ADVERTENCIA DE SOLO SE HAN DEFINIDO CONDICIONES INCIALES*/
                                        printf("\nWarnning: Se definieron solo las C.I \n\n"); 
                                    }
        | parametros             {   
                                        // IMPIMRE ADVERTENCIA DE SOLO SE HAN DEFINIDO PARAMETROS */
                                        printf("\nWarnning: Se definieron solo los parametros\n\n"); 
                                    }
        | parametros modelo ciniciales 
        
        
        
        
ciniciales: STRINI condiciones STOP         { 
                                                /* IMPIMRE CONDICIONES INICIALES */
                                                int lfun;
                                                char nombre_fun[25];
                                                for(int i=0;i<nfuni;i++)
                                                {
                                                    lfun=strlen(n_fun[i]);                                                                                                       sprintf(nombre_fun,"%s",n_fun[i]);
                                                    nombre_fun[lfun-1]='\0'; 
                                                    printf("%s=%0.2f\n",nombre_fun,val_ciniciales[i]);
                                                }
                                                /* FIN DE IMPIMRE CONDICIONES INICIALES */
                                            }

condiciones: condiciones MORE condiciones {}
           | INITALC EQL exppc        {   char nombre_fun[25];
                                         char nombre_ci[25];
                                         char bbf1[20];
                                        int i=0,lfun,bandera=1,lcin=0;
                                        if(nfuni>0)
                                        {
                                            lcin=strlen($1);
                                            sprintf(nombre_ci,"%s",$1);
                                            nombre_ci[lcin-2]='\0';
                                            for(i=0;i<nfuni;i++)
                                            {
                                                lfun=strlen(n_fun[i]);
                                                
                                                sprintf(nombre_fun,"%s",n_fun[i]);
                                                nombre_fun[lfun-1]='\0';
                                                //nombre_fun[lfun]='0';
                                               
                                               // printf("FUNCION:%s  =  %s\n",nombre_fun,$1);                                
                                                if(!strcmp(nombre_fun,nombre_ci))
                                                {   bandera=0; 
                                                    break;
                                                }
                                                
                                            }
                                            
                                            if(!bandera)
                                            { //printf("existe %s=%s\n",$1,$3);
                                                val_ciniciales[ncinii]=atof($3);
                                               // printf("\n%0.2f\n",val_ciniciales[ncinii]);
                                                ncinii++;
                                            }
                                            
                                            else
                                            {   
                                                
                                                printf("%s' no definida\n",nombre_ci);
                                            }
                                        }
                                        else
                                        {
                                            printf("No se han declarado las ecuaciones..\n");
                                            exit(1);
                                        }
                                    }
                                    
exppc:   NUM                        { sprintf($$,"%s",$1);}
        |OPA NUM                     {
                                            switch($1) 
                                            {	case '+': sprintf($$,"%s",$2); break;
                                                case '-': sprintf($$,"-%s",$2); break;
                                            }    
                                    }
                        

                

        
        
parametros: STRPAR ini  STOP       {    if(val_parametros[_tf]<=val_parametros[_ti])    {printf("Error: tf menor o igual q ti\n"); exit(1);}
                                        if(val_parametros[_dt]<= 0.001)                 {printf("Error: Se excedio paso integracion dt_min=0.001\n"); exit(1);}
                                        
                                        if(npari<NUM_PAR_DEF)
                                        {    printf("\n Se definieron %d parametro(s), %d por default\n",npari,NUM_PAR_DEF-npari); 
                                            
                                        }   
                                        printf("//--- Parametros ---//\n");
                                         for(int i=0;i<NUM_PAR_DEF-2;i++)
                                            printf("%s=%0.2f ",n_parametros[i],val_parametros[i]); 
                                         for(int i=NUM_PAR_DEF-2;i<NUM_PAR_DEF;i++)
                                            printf("%s=%d ",n_parametros[i],(int)val_parametros[i]); 
                                        printf("\n");
                                    }


ini:  
        ini MORE ini             {sprintf($$,"%s%s",$1,$3);}
        | TI EQL expp          {sprintf($$," %s=%s",$1,$3); npari++; val_parametros[_ti]=atof($3);}
        | TF EQL expp        {sprintf($$," %s=%s",$1,$3); npari++; val_parametros[_tf]=atof($3);}
        | DT EQL expp         {sprintf($$," %s=%s",$1,$3); npari++; val_parametros[_dt]=atof($3);}
        | NINPUT EQL expp        {sprintf($$," %s=%s",$1,$3); npari++; val_parametros[_entradas]=atof($3);}
        | NOUTPUT EQL expp       {sprintf($$," %s=%s",$1,$3); npari++; val_parametros[_salidas]=atof($3);}
        

expp:   NUM                      {   sprintf($$,"%s",$1); }



        
modelo: STRT vvar STOP  		{ imprime($2);   }


vvar:   
        vvar MORE vvar       { sprintf($$,"%s%s",$1,$3);}
        |  res               { sprintf($$,"%s",$1);}
        |  deq               { sprintf($$,"%s","");}
        
      

res:
        VAR EQL exp         {  
                                sprintf($$,"  #define %s %s\n",$1,$3);
                                sprintf(n_var[nvari++],"%s",$1);		                                        
                            }
deq:
            DEQQ EQL exp    {   int len=strlen($1);
                                $1[len-1]='p';
                                //almacena la defincion
                                sprintf(def_fun[nfuni],"return %s;",$3);
                               
                               //guarda el nombre y aumenta el indice
                                sprintf(n_fun[nfuni++],"%s",$1);
                            }

			

									
exp:    exp OPA exp    			{ switch($2)
										  { case '-':    sprintf($$,"%s(%s,%s)",op_r,$1,$3); break;
											 case '+':    sprintf($$,"%s(%s,%s)",op_s,$1,$3); break;   
										  }
										}
		  | exp OPA1 exp  		{ switch($2)
										  { case '/':   cero=encuentracero($3);
                                                        if(!cero)
                                                            sprintf($$,"%s(%s,%s)",op_d,$1,$3); 
                                                        else
                                                        {
                                                            sprintf($$,"Error Division por cero.."); 
                                                            printf("%s",$$);
                                                            exit(1);
                                                        }
                                                            
                                                        break;   
														  
											case '*':    sprintf($$,"%s(%s,%s)",op_m,$1,$3); break;   
										  }
										}
		  | OPA exp %prec OPA1  { switch($1) 
                                {	case '+': sprintf($$,"%s",$2); break;
                                    case '-': sprintf($$,"%s(%s)",op_ng,$2); break;
                                }    
                              }
		  | ffun		%prec VAR	{	
                                        /*ṕasa directo $$=$1*/	
                                    }
		  
		  | NUM 						{  sprintf($$,"%s(%s)",op_n,$1);    	}
		  | VAR               {
                                        /* if(no_existe_var($1))
                                            {
                                                printf("%s :Indefinida...\n",$1);
                                                exit(1);
                                            }*/
											 
		
											 sprintf($$,"%s",$1);						
                                }
        |OFNT exp CFNT          { sprintf($$,"%s",$2);}
		  
ffun:	
		 VAR OFNT exp CFNT	   {   int existe=buscar_funcion($1);
                                   if(existe)
                                    sprintf($$,"%s(%s)",$1,$3);
                                   else
                                   {
                                        sprintf($$,"Funcion %s no definida..\n",$1); 
										printf("%s",$$); 
										exit(1);
                                   }
                                }

%%
//-- FUNCTION DEFINITIONS --------------1-------------------

char ibuffer[1024];
char obuffer[1024];
FILE *f;


int encuentracero(char *s)
{
   
        if(strcmp(s,"_n(0)") || strcmp(s,"_n(0.0)") || strcmp(s,"n(0.00)") || strcmp(s,"_n(0.000)"))
            return 0;
        else 
            if(strcmp(s,"_ng(_n(0))") || strcmp(s,"_ng(_n(0.0))") || strcmp(s,"_ng(_n(0.00))") || strcmp(s,"_ng(_n(0.000))"))
            return 0;
        else
            return 1;
            
   
}

int buscar_funcion(char *funcion_entrada)
{
    int existe=0,i=0;
    //int l=strlen(funciones_definidas);
    //printf("\n%d",l);
    
    for(;i<NUM_FUN_DEF && !existe; existe=!strcmp(funciones_definidas[i],funcion_entrada),i++)
    {
       // printf("\n%d",i);
    }
    return existe;
}

int no_existe_var(char *v)
{	
	int xxi=0, xxj=1;
	for(;xxi<nvari && xxj;xxi++)
	{
		xxj=strcmp(n_var[xxi],v);
	}
	return xxj;
}

void printf_add_var(void)
{
    int xxi=0, xxj=1;
    for(int xxi=0;xxi<nvari;xxi++)
    {
        printf("   float %s;\n",n_var[xxi]);
        fprintf(f,"   float %s;\n",n_var[xxi]);
    }
}

void imprime_var_io(char* c0)
{
    char bbf[50];
    sprintf(bbf,"   float x0[%d]={%s};\n",nfuni,c0);
    printf("%s",bbf);   fprintf(f,"%s",bbf);

    sprintf(bbf,"   float xs[%d];\n",nfuni);
    printf("%s",bbf);   fprintf(f,"%s",bbf);
    sprintf(bbf,"   char output[%d][15];\n",nfuni+1);
    printf("%s",bbf);   fprintf(f,"%s",bbf);
    
    
    printf("   float ti=0,tf=5,dt=0.01,t,u=0;\n");
    fprintf(f,"   float ti=0,tf=5,dt=0.01,t,u=0;\n");
    
}
void printf_add_var_define(void)
{
    int xxi=0, xxj=1;
    for(int xxi=0;xxi<nvari;xxi++)
    {
        printf("#define %s;\n",n_var[xxi]);
        fprintf(f,"#define %s;\n",n_var[xxi]);
    }
}

void printf_add_fun()
{
    int xxi=0, len=0;
    char bbf_fun[200];
    char bbf0[30];
    
    sprintf(bbf0,"%s_f",n_fun[xxi]);
    sprintf(bbf_fun,"%s",bbf0);
   
    for( xxi=1; xxi<nfuni; xxi++)
    {    sprintf(bbf0,",%s_f",n_fun[xxi]);
         strcat(bbf_fun,bbf0);
    }
    printf("   float (*funcion[%d])(float *,float, float)={%s};\n",nfuni,bbf_fun);
    fprintf(f,"   float (*funcion[%d])(float *,float, float)={%s};\n",nfuni,bbf_fun);
    
}



void print_cabeceras(void)
{
    if((f=fopen("ccode_generate.c","a"))==NULL)
    {   printf("Error al crear archivo de salida \n"); return; }
    
    printf("\n-------------------------------\n");
    printf(" #include<stdlib.h> \n");   fprintf(f," #include<stdlib.h> \n");
    printf(" #include<stdio.h> \n");    fprintf(f," #include<stdio.h> \n");
    printf(" #include<string.h> \n");   fprintf(f," #include<string.h> \n");
    printf(" #include<math.h> \n");     fprintf(f," #include<math.h> \n");
    printf(" \n");
    //printf(" #define ORDEN %d",nfuni);
   //  printf_add_var_define();
    
    
    
}

void printf_def_func_p()
{
    char bbf0[100]={"\n   float "};
    char bbf1[20];
    char nombre_var_fun[20];
    
    int i=0,l;
    
    l=strlen(n_fun[i]);
    sprintf(nombre_var_fun,"%s",n_fun[i]);
    nombre_var_fun[l-1]='\0';
    sprintf(bbf1,"%s=x[%d]",nombre_var_fun,i);
    strcat(bbf0,bbf1);
    
    
    for(i=1; i<nfuni;i++)
    {   l=strlen(n_fun[i]);
        sprintf(nombre_var_fun,"%s",n_fun[i]);
        nombre_var_fun[l-1]='\0';
        
        sprintf(bbf1,", %s=x[%d]",nombre_var_fun,i);
        strcat(bbf0,bbf1);
    }
    strcat(bbf0,";\n");
    
    for (i=0;i<nfuni;i++)
    {
        //impresion consola
        printf(" float  %s_f(float *x, float u, float t)\n {%s   %s\n }\n",n_fun[i],bbf0,def_fun[i]);
        //impresion en archiv
        fprintf(f," float  %s_f(float *x, float u, float t)\n {%s   %s\n }\n",n_fun[i],bbf0,def_fun[i]);
    }
    
    printf("\n");
    fprintf(f,"\n");
    
}

void print_funciones(void)
{
    
    //impresion consola
    printf("\n");
    printf(" float _n (float xn) { return xn; } \n");
    printf(" float _ng (float xng) { return -xng; } \n");
    printf(" float _s (float xa,float xb) {return xa+xb;} \n");
    printf(" float _r (float xa,float xb) {return xa-xb;} \n");    
    printf(" float _m (float xa,float xb) {return xa*xb;} \n");
    printf(" float _d (float xa,float xb) {return xa/xb;} \n");
    printf(" float euler(int i,float *x,float u,float t,float dt,float (*funcion)(float *, float, float))\n");
    printf(" { return dt*funcion(x,u,t)+ x[i]; }");
    //impresion en archivo
    fprintf(f,"\n");
    fprintf(f," float _n (float xn) { return xn; } \n");
    fprintf(f," float _ng (float xng) { return -xng; } \n");
    fprintf(f," float _s (float xa,float xb) {return xa+xb;} \n");
    fprintf(f," float _r (float xa,float xb) {return xa-xb;} \n");
    fprintf(f," float _m (float xa,float xb) {return xa*xb;} \n");
    fprintf(f," float _d (float xa,float xb) {return xa/xb;} \n");
    fprintf(f," float euler(int i,float *x,float u,float t,float dt,float (*funcion)(float *, float, float))\n");
    fprintf(f," { return dt*funcion(x,u,t)+ x[i]; }");
    
    

}
void print_for(char *cuerpo)
{
    printf("     for(i=0;i<%d;i++)\n",nfuni);	       //calcula x[n+1]
    printf(cuerpo);
    
    fprintf(f,"     for(i=0;i<%d;i++)\n",nfuni);
    fprintf(f,cuerpo);
    
    
}

void printf_imprime_seniales()
{
    char bfr[500]={},porcientos[50]={},vrbl[20]={},variables[200]={};
    int i=0;
    strcat(porcientos,"%s");
    sprintf(vrbl,"%s[%d]","output",i);
    strcat(variables,vrbl);
    
    for (i=1;i<nfuni+1;i++)
    {
        strcat(porcientos,",%s");
        sprintf(vrbl,"%s[%d]",",output",i);
        strcat(variables,vrbl);
    }
    
    sprintf(bfr,"     PRINTF(\"%s\\n\",%s);",porcientos,variables);
    
    //impresion consola
    printf("\n%s\n",bfr);
    //impresion archivo
    fprintf(f,"\n%s\n",bfr);
    
}


void print_main(char* xf)
{
   
    printf("\n");
    fprintf(f,"\n");
    
    //impresion de las variables
    sprintf(ibuffer,"\n%s\n",xf);
    printf("%s",ibuffer);
    fprintf(f,"%s",ibuffer);
    
    //impresion de las definciones de xp
    printf_def_func_p();
    
    
    //impresion del main
    printf(" static void main_task (void) \n {\n");
    fprintf(f," static void main_task (void) \n {\n");
    
   // impresion de las variables x0 y xs
   char bfrci[50];
   strcpy(bfrci,"0.0");
   
   for( int ni=1; ni<nfuni; ni++)
        strcat(bfrci,",0.0");
        
    imprime_var_io(bfrci);
    printf_add_fun();
    
    printf("   int i;\n");
    printf("\n   const TickType_t xDelay = dt*1000/portTICK_PERIOD_MS;\n\n");
    
    fprintf(f,"   int i;\n");
    fprintf(f,"\n   const TickType_t xDelay = dt*1000/portTICK_PERIOD_MS;\n\n");
    
    printf("   // INCIO rutina de pausa con boton\n\n");
    printf("   // FIN   rutina de pausa con boton\n\n");
    fprintf(f,"   // INCIO rutina de pausa con boton\n\n");
    fprintf(f,"   // FIN rutina de pausa con boton\n\n");
    
	printf("   for(t=ti;t<tf;t+=dt)\n"); fprintf(f,"   for(t=ti;t<tf;t+=dt)\n");
	printf("   {\n");  fprintf(f,"   {\n");
	
	printf("     while(!ADC16_GetChannelStatusFlags(ADC16_1_PERIPHERAL,0U));\n");
	fprintf(f,"     while(!ADC16_GetChannelStatusFlags(ADC16_1_PERIPHERAL,0U));\n");
	
	
	printf("     u=ADC16_GetChannelConversionValue(ADC16_1_PERIPHERAL,0U)*0.0080586;\n\n");
	fprintf(f,"     u=ADC16_GetChannelConversionValue(ADC16_1_PERIPHERAL,0U)*0.0080586;\n\n");
	
	print_for("     {\n       xs[i]=euler(i,x0,u,t,dt,funcion[i]);\n       x0[i]=xs[i];\n       ftoa(xs[i],output[i+1],3);\n     }\n");
	
	
	printf("\n     ftoa(t,output[0],3);"); fprintf(f,"\n     ftoa(t,output[0],3);");
	printf_imprime_seniales();
    printf("     vTaskDelay(xDelay);\n");
    fprintf(f,"     vTaskDelay(xDelay);\n");
	printf("   }\n"); fprintf(f,"   }\n");  
    
    
    
    printf("\n\n    // INCIO rutina de pausa con boton\n\n");
    printf("    // FIN   rutina de pausa con boton\n");
    fprintf(f,"   // INCIO rutina de pausa con boton\n\n");
    fprintf(f,"   // FIN rutina de pausa con boton\n\n");
    
    printf("    for(;;); \n");
    fprintf(f,"    for(;;); \n");

    
    printf(" } \n");
    fprintf(f," } \n"); 
    printf("\n-------------------------------\n");
    
    fclose(f);
}

int abrir_archivo()
{
    if((f=fopen("ccode_generate.c","w"))==NULL)
    {   printf("Error al crear archivo de salida \n"); return 1; }
    fclose(f);
}


int imprime (char* f)
{
    if(abrir_archivo())
        return 1;
    print_cabeceras();
    print_funciones();
    print_main(f);
    //print_openmain(f);
    //print_varmain(f)
    // print_closemain(f);

}

int add_fun(char *f)
{
    printf("%s",f);
}

int main(int argc, char **argv)
{
    
    if ( (argc > 1) && (freopen(argv[1], "r", stdin) == NULL) ) 
    {
        cerr << argv[0] << ": File " << argv[1] << " cannot be opened.\n";
        exit(1);
    }
    printf("Traductor inicializado...\n");  
    yyparse();
    //entero();
    return 0;
}
 

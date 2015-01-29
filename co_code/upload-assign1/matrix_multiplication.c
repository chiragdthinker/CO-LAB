#include<stdio.h>
int main(){

	int a[10][20],b[20][30],i,j,k;
	long long int c[10][30];
	FILE *f=fopen("values.dat","r");
	FILE *s=fopen("hexvalues.dat","w");
	for(i=0;i<10;i++)
	{
		for(j=0;j<20;j++)
		{
			fscanf(f,"%d",&a[i][j]);
		}
	}

	for(i=0;i<20;i++)
	{
		for(j=0;j<30;j++)
		{
			fscanf(f,"%d",&b[i][j]);
		}
	}
	
	for(i=0;i<10;i++)
	{
		for(j=0;j<30;j++)
		{
			c[i][j]=0;
			
			for(k=0;k<20;k++)
			{
				c[i][j]+= (a[i][k]*b[k][j]);
			}	
			
			fprintf(s,"dq 0x%x\n",c[i][j]);
		}
	}
	
	fclose(f);
	fclose(s);
}
	
		
	

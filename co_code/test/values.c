#include<stdio.h>
main()
{
	int i=0;
	for(i=0;i<800;++i)
	{
		printf("%d\n",(i*i*i)%800+23);
	}
}

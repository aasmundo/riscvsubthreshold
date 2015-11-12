//#include <stdio.h>

void quicksort(int [10],int,int);

int main(){
  int size = 20, i;

  int x[20] = {698643762, 
    -379260505, 
    177834380,
    -902075336,
    92808423,
    -473536481,
    -379347579,
    519300617,
    -977933261,
    674507125,
    316025191,
    43258742,
    -523064697,
    -54377939,
    448883006,
    805551209,
    31288179,
    -838422794,
    -138133648,
    339987605};

  quicksort(x,0,size-1);

  //printf("Sorted elements: ");
  //for(i=0;i<size;i++)
    //printf(" %d",x[i]);

  return 0;
}

void quicksort(int x[10],int first,int last){
    int pivot,j,temp,i;

     if(first<last){
         pivot=first;
         i=first;
         j=last;

         while(i<j){
             while(x[i]<=x[pivot]&&i<last)
                 i++;
             while(x[j]>x[pivot])
                 j--;
             if(i<j){
                 temp=x[i];
                  x[i]=x[j];
                  x[j]=temp;
             }
         }

         temp=x[pivot];
         x[pivot]=x[j];
         x[j]=temp;
         quicksort(x,first,j-1);
         quicksort(x,j+1,last);

    }
}
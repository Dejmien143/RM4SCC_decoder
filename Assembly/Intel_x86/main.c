#include <stdio.h>
#include <stdlib.h>

int decodeRM4SCC(unsigned char *source_bitmap, int scan_line_no, char *text);

int main(void)
{
    char *buff;
    FILE *imgFile;
    char text[] = "           ";
    unsigned int len;

    imgFile = fopen("source.bmp", "rb");

    fseek(imgFile, 0, SEEK_END);
    len = ftell(imgFile);
    fseek(imgFile, 0, SEEK_SET);

    buff = (char *)malloc(sizeof(unsigned char) * len);
    if (buff == NULL)
    {
        fclose(imgFile);
        return -1;
    }

    fread(buff, len, 1, imgFile);
    fclose(imgFile);

    int result = decodeRM4SCC(buff + 54, 15, text);
    if (result == 1)
        printf("Wrong start symbol");
    else if (result == 0)
        printf("%s\n", text);
    else if (result == 2)
        printf("No start symbol found");

    return 0;
}

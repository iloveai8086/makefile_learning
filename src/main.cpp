//
// Created by ros on 6/28/22.
//

#include <stdio.h>
#include <string>
#include <fstream>
#include <curl/curl.h>

using namespace std;

size_t write_data(const void* buffer,size_t count,size_t size,void* user_data){
    string* stream = static_cast<string*>(user_data);
    const char* pbytes = static_cast<const char*>(buffer);
    stream->append(pbytes,count*size);
    return count*size;
}

string download(const string& url){
    CURL *curl = curl_easy_init();
    string response;

    curl_easy_setopt(curl,CURLOPT_URL,url.c_str());
    curl_easy_setopt(curl,CURLOPT_WRITEFUNCTION,&write_data);
    curl_easy_setopt(curl,CURLOPT_WRITEDATA,&response);
    curl_easy_setopt(curl,CURLOPT_SSL_VERIFYPEER,0L);
    curl_easy_setopt(curl,CURLOPT_SSL_VERIFYHOST,1);

    CURLcode code = curl_easy_perform(curl);
    if(code != CURLE_OK){
        printf("has error: code = %d,message: %s \n",code, curl_easy_strerror(code));
    }
    curl_easy_cleanup(curl);
    return response;

}


int main(){
    string sxai = download("https://pic3.zhimg.com/v2-28ba7d2db16b99c87b10c68db590d53e_r.jpg");
    printf("sxai.size = %d byte \n",sxai.size());
    ofstream of("sxai.jpg",ios::binary|ios::out);
    of.write(sxai.data(),sxai.size());
    of.close();
    return 0;
}


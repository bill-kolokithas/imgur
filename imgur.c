#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <curl/curl.h>

#define CLIENT_ID "c3d5102cafbba4c"
#define CMDLEN 256

typedef struct {
	char *buffer;
	size_t size;
} Mem_buffer;

size_t curl_write_memory(char *data, size_t size, size_t elements, void *membuf) {

	Mem_buffer *mem = membuf;
	size_t total_size = size * elements;

	mem->buffer = realloc(mem->buffer, mem->size + total_size + 1);
	if (!mem->buffer)
		return 0;

	memcpy(&(mem->buffer[mem->size]), data, total_size);
	mem->size += total_size;
	mem->buffer[mem->size] = '\0';

	return total_size;
}

int main(int argc, char *argv[]) {

	CURL *curl;
	CURLcode code;
	struct curl_httppost *firstitem = NULL, *lastitem = NULL;
	struct curl_slist *headers = NULL;
	Mem_buffer mem = { NULL, 0 };
	char cmd[CMDLEN], *url, *temp = NULL;
	int status;

	if (argc != 2) {
		fprintf(stderr, "Usage: %s <path/to/image.(png|jpg)>\n", argv[0]);
		return EXIT_FAILURE;
	}

	curl = curl_easy_init();
	if (!curl)
		return EXIT_FAILURE;

	headers = curl_slist_append(headers, "Authorization: Client-ID " CLIENT_ID);
	curl_formadd(&firstitem, &lastitem,
			CURLFORM_COPYNAME, "image",
			CURLFORM_FILE, argv[1],
			CURLFORM_END);

	curl_easy_setopt(curl, CURLOPT_URL, "https://api.imgur.com/3/upload.xml");
	curl_easy_setopt(curl, CURLOPT_HTTPHEADER, headers);
	curl_easy_setopt(curl, CURLOPT_HTTPPOST, firstitem);
	curl_easy_setopt(curl, CURLOPT_WRITEFUNCTION, curl_write_memory);
	curl_easy_setopt(curl, CURLOPT_WRITEDATA, &mem);

	code = curl_easy_perform(curl);
	if (code != CURLE_OK || !mem.buffer) {
		fprintf(stderr, "Error: %s\n", curl_easy_strerror(code));
		return EXIT_FAILURE;
	}

	url = strstr(mem.buffer, "http");
	if (url)
		temp = strstr(url, "</");

	if (!temp) {
		system("notify-send 'Upload error'");
		return EXIT_FAILURE;
	}

	*temp = '\0';
	snprintf(cmd, CMDLEN, "echo -n %s | xclip -selection c", url);
	status = system(cmd);
	if (WEXITSTATUS(status) == 127)
		fputs(url, stdout); // print the url to stdout if xclip is not present

	system("notify-send 'Upload complete'");

	free(mem.buffer);
	curl_formfree(firstitem);
	curl_slist_free_all(headers);
	curl_easy_cleanup(curl);
	return EXIT_SUCCESS;
}

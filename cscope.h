//
//  cscope.h
//  SingleView
//
//  Created by Guozhen Li on 12/5/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#ifndef SingleView_cscope_h
#define SingleView_cscope_h

void cscope_set_base_dir(const char* base_dir);
void cscope_build(const char* out_file_name, const char* file_list_f);
char* cscope_find_this_symble(const char* symble_name, const char* out_file_name, 
                             const char* file_list_f);
char* cscope_find_global(const char* symble_name, const char* out_file_name, 
                        const char* file_list_f);
char* cscope_find_called_functions(const char* symble_name, const char* out_file_name, 
                                 const char* file_list_f);
char* cscope_find_functions_calling_a_function(const char* symble_name, const char* out_file_name, 
                                 const char* file_list_f);
char* cscope_find_text_string(const char* symble_name, const char* out_file_name, 
                                              const char* file_list_f);
char* cscope_find_a_file(const char* symble_name, const char* out_file_name, 
                             const char* file_list_f);
char* cscope_find_files_including_a_file(const char* symble_name, const char* out_file_name, 
                             const char* file_list_f);

#endif

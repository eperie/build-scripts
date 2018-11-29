// Credits:
// Marius Storm-Olsen <mstormo_git@storm-olsen.com>
// Johannes Sixt <johannes.sixt@telecom.at>
// Adapted from their git mingw compatibility patch
// https://buffet.cs.clemson.edu/vcs/u/pkilgo/git/commits/rev/5411bdc4e4b170a57a61b2d486ab344896c41500/

#pragma once
int mingw_lstat(const char *file_name, struct stat *buf);


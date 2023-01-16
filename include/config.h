/*
 * LBBS -- The Lightweight Bulletin Board System
 *
 * Copyright (C) 2023, Naveen Albert
 *
 * Naveen Albert <bbs@phreaknet.org>
 *
 */

/*! \file
 *
 * \brief Config parser
 *
 */

/* Forward declarations of opaque structs */
struct bbs_config;
struct bbs_config_section;
struct bbs_keyval;

/*!
 * \brief Retrieve a config setting
 * \param cfg
 * \param section_name Name of section
 * \param key Name of key
 * \retval value on success, NULL if section or key not found
 */
const char *bbs_config_val(struct bbs_config *cfg, const char *section_name, const char *key);

/*!
 * \brief Retrieve a config setting
 * \param section
 * \param key Name of key
 * \retval value on success, NULL if section or key not found
 */
const char *bbs_config_sect_val(struct bbs_config_section *section, const char *key);

/*!
 * \brief Set a string buffer with a value from a config setting
 * \param cfg
 * \param section_name Name of section
 * \param key Name of key
 * \param buf Buffer to fill
 * \param len Size of buffer
 * \retval 0 if set, -1 if not set (config value not found)
 */
int bbs_config_val_set_str(struct bbs_config *cfg, const char *section_name, const char *key, char *buf, size_t len);

/*!
 * \brief Set an integer with a value from a config setting
 * \param cfg
 * \param section_name Name of section
 * \param key Name of key
 * \param var int variable to set
 * \retval 0 if set, -1 if not set (config value not found)
 */
int bbs_config_val_set_int(struct bbs_config *cfg, const char *section_name, const char *key, int *var);

/*!
 * \brief Set an integer with an unsigned value from a config setting
 * \param cfg
 * \param section_name Name of section
 * \param key Name of key
 * \param var int variable to set
 * \retval 0 if set, -1 if not set (config value not found)
 */
int bbs_config_val_set_uint(struct bbs_config *cfg, const char *section_name, const char *key, unsigned int *var);

/*!
 * \brief Set a true/false integer flag with a value from a config setting
 * \param cfg
 * \param section_name Name of section
 * \param key Name of key
 * \param int Pointer to integer
 * \retval 0 if set, -1 if not set (config value not found)
 */
int bbs_config_val_set_true(struct bbs_config *cfg, const char *section_name, const char *key, int *var);

/*!
 * \brief Traverse a config section
 * \param cfg
 * \param keyval Previous key value pair. NULL to start at beginning.
 * \returns Next config key value pair
 */
struct bbs_keyval *bbs_config_section_walk(struct bbs_config_section *section, struct bbs_keyval *keyval);

/*!
 * \brief Traverse a config
 * \param cfg
 * \param section Previous config section. NULL to start at beginning.
 * \returns Next config section
 */
struct bbs_config_section *bbs_config_walk(struct bbs_config *cfg, struct bbs_config_section *section);

/*! \brief Get the key of a config key value pair */
const char *bbs_keyval_key(struct bbs_keyval *keyval);

/*! \brief Get the value of a config key value pair */
const char *bbs_keyval_val(struct bbs_keyval *keyval);

/*! \brief Get a config section's name */
const char *bbs_config_section_name(struct bbs_config_section *section);

/*!
 * \brief Destroy (free) a BBS config
 * \param cfg
 * \retval 0 on success, -1 on failure
 */
int bbs_config_free(struct bbs_config *cfg);

/*! \brief Destroy all existing configs (used at shutdown) */
void bbs_configs_free_all(void);

/*!
 * \brief Return a BBS config object, parsing the config if necessary
 * \param name Config file name
 * \param usecache If config object exists, use cached version.
 *                 Configs that have not been parsed yet will always be parsed.
 *                 Specify 0 to always reparse configs.
 * \retval config on success, NULL on failure
 */
struct bbs_config *bbs_config_load(const char *name, int usecache);

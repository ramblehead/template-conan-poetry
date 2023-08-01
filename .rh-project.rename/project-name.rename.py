def rename(config, utils):
    return f"{utils.kebab_case(config['project_name'])}.txt"

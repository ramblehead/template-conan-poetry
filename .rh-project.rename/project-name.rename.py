def rename(config, utils):
    return f"{utils.to_kebab_case(config['project_name'])}.txt"

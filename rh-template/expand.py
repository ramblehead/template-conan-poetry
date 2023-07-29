# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import .config

def expand_content(model_path, templatePath, filePath):
  packagePath = model_path.parent
  packageName = packagePath.stem
  packageInitPath = packagePath / '__init__.py'
  spec = importlib.util.spec_from_file_location(packageName, packageInitPath)
  package = importlib.util.module_from_spec(spec)
  sys.modules[packageName] = package
  spec.loader.exec_module(package)

  moduleName = model_path.stem
  model = importlib.import_module(f'{packageName}.{moduleName}')

  if hasattr(model, moduleName): data = getattr(model, moduleName)
  elif hasattr(model, 'getData'): data = model.getData()
  else: data = model.data

  relpath = os.path.relpath

  data['_meta'] = AutoCodeMetadata({
    # importlib can be used to import modules directly in mako files
    'importlib': importlib,
    'templateName': templatePath.stem,
    'templatePath': templatePath,
    'modelName': model_path.stem,
    'model_path': model_path,
    'filePath': filePath,
    'templateRelPath': relpath(templatePath, filePath.parent),
    'modelRelPath': relpath(model_path, filePath.parent),
  })

  templateLookup = TemplateLookup(directories=[templatePath.parent])
  template = templateLookup.get_template(templatePath.name)

  print(template.render(**data), end='')

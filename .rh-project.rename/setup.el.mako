## Hey Emacs, this is -*- coding: utf-8 -*-
<%
  project_name = utils.to_kebab_case(config["project_name"])
%>\
;; Hey Emacs, this is -*- coding: utf-8 -*-

(${project_name}-mode 1)
(${project_name}-setup)

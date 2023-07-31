#!/usr/bin/env -S python
# Hey Emacs, this is -*- coding: utf-8; mode: python -*-

import subprocess
from pathlib import Path

from rh_template import expand


def implode() -> None:
    s_path = Path(__file__)
    sd_path = (s_path.parent).resolve(strict=True)
    rh_template_dir_path = sd_path / "rh_template"

    print("Imploding...")

    subprocess.Popen(
        f"python -c \"import shutil, time; time.sleep(1); shutil.os.remove('{s_path}'); shutil.rmtree('{rh_template_dir_path}');\"",
        shell=True,
    )


if __name__ == "__main__":
    expand.expand_all_project_templates(delete_templates=True)
    expand.do_renaming(delete_origins=True)
    implode()

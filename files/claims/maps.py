from os.path import exists
import shutil

# copies maps from BE over to website, ensuring they are always updated
# -- IMPORTANT -- the system only works upon correct relative paths
#                 meaning it will need particular setup of BE/website
#                 when working on another device

MAPS = {
    # FROM : TO
    "../../../Baedoor_Encyclopaedia/Assets/Gridmaps/Arennan_Regions.png":
        "../art/maps/bae_arennan.png",
    "../../../Baedoor_Encyclopaedia/Assets/Gridmaps/Rossevette_Regions.png":
        "../art/maps/bae_rossevette.png",
    "../../../Baedoor_Encyclopaedia/Assets/Gridmaps/Kaer_Regions.png":
        "../art/maps/bae_kaer.png",
    "../../../Baedoor_Encyclopaedia/Assets/Gridmaps/Ansur_Regions.png":
        "../art/maps/bae_ansur.png",
    "../../../Baedoor_Encyclopaedia/Assets/Gridmaps/BaedoorIsland_Regions.png":
        "../art/maps/bae_baedoor.png",
    "../../../Baedoor_Encyclopaedia/Assets/Gridmaps/Kacari_Regions.png":
        "../art/maps/bae_kacari.png",
}

for MAP in MAPS:
    if exists(MAP):
        shutil.copy(MAP, MAPS[MAP])
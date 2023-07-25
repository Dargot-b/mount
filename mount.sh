#!/bin/bash

# Funkcja wyświetlająca dostępne dyski
function display_available_disks() {
  echo -e "\e[1;32m******************************"
  echo "DOSTĘPNE DYSKI:"
  echo "******************************\e[0m"
  lsblk
  echo -e "\e[1;32m******************************\e[0m"
}

# Funkcja tworząca partycję na wybranym dysku
function create_partition() {
  echo -e "\e[1;32m******************************"
  echo "TWORZENIE PARTYCJI"
  echo "******************************\e[0m"
  read -p "Podaj nazwę dysku, na którym chcesz utworzyć partycję (np. sdb, sdc, sdd): " disk_name
  sudo fdisk /dev/${disk_name}
  echo -e "\e[1;32m******************************\e[0m"
}

# Funkcja formatująca partycję z wyborem systemu plików
function format_partition() {
  echo -e "\e[1;32m******************************"
  echo "FORMATOWANIE PARTYCJI"
  echo "******************************\e[0m"
  read -p "Podaj nazwę partycji do sformatowania (np. /dev/sdb1): " partition_name
  echo "Wybierz system plików do sformatowania:"
  echo "1. ext4"
  echo "2. ntfs"
  read -p "Wybór (1 lub 2): " fs_choice

  case $fs_choice in
    1)
      sudo mkfs.ext4 ${partition_name}
      ;;
    2)
      sudo mkfs.ntfs ${partition_name}
      ;;
    *)
      echo "Nieprawidłowy wybór. Zakończono."
      exit 1
      ;;
  esac
  echo -e "\e[1;32m******************************\e[0m"
}

# Funkcja montująca dysk w wybranym katalogu
function mount_disk() {
  echo -e "\e[1;32m******************************"
  echo "MONTOWANIE DYSKU"
  echo "******************************\e[0m"
  read -p "Podaj nazwę dysku do zamontowania (np. sdb, sdc, sdd): " disk_name
  read -p "Podaj nazwę katalogu, w którym chcesz zamontować dysk: " mount_directory

  # Sprawdzenie, czy dysk istnieje
  if [ -e "/dev/${disk_name}" ]; then
    # Sprawdzenie, czy katalog montowania istnieje
    if [ ! -d "/mnt/${mount_directory}" ]; then
      sudo mkdir -p "/mnt/${mount_directory}"
    fi

    # Montowanie dysku
    sudo mount "/dev/${disk_name}" "/mnt/${mount_directory}"
    echo "Dysk /dev/${disk_name} został zamontowany w /mnt/${mount_directory}."

    # Dodanie wpisu do pliku /etc/fstab
    echo "/dev/${disk_name}   /mnt/${mount_directory}   auto   defaults   0   0" | sudo tee -a /etc/fstab
    echo "Dodano wpis do /etc/fstab dla automatycznego montowania dysku."
  else
    echo "Podany dysk nie istnieje. Zakończono."
  fi
  echo -e "\e[1;32m******************************\e[0m"
}

# Interaktywny wybór opcji
while true; do
  echo -e "\e[1;32m******************************"
  echo "MENU GŁÓWNE"
  echo "******************************\e[0m"
  echo "1. Wyświetl dostępne dyski"
  echo "2. Utwórz partycję na dysku"
  echo "3. Sformatuj partycję"
  echo "4. Zamontuj dysk"
  echo "5. Wyjdź"
  echo -e "\e[1;32m******************************\e[0m"
  read -p "Wybierz opcję (1, 2, 3, 4 lub 5): " option

  case $option in
    1)
      display_available_disks
      ;;
    2)
      create_partition
      ;;
    3)
      format_partition
      ;;
    4)
      mount_disk
      ;;
    5)
      echo -e "\e[1;32mZakończono skrypt.\e[0m"
      break
      ;;
    *)
      echo "Nieprawidłowy wybór."
      ;;
  esac
done

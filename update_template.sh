#!/bin/bash

if [ "$1" == "" ]; then
    echo "Usage: $0 <VERSION>"
    exit 1
fi

workspace=`pwd`

if [ -d ../CumulusTemplateCumulus ]; then
    rm -rf ../CumulusTemplateCumulus
fi

previous_version=`grep 'version.npsp=' version.properties | sed -e 's/version.npsp=//g'`

# Clone the Cumulus repo to ../CumulusTemplateCumulus
cd ..
git clone https://github.com/SalesforceFoundation/Cumulus CumulusTemplateCumulus
if [ $? != 0 ]; then echo "ERROR: Failed to clone Cumulus repository"; exit 1; fi

# Check out the tag
cd CumulusTemplateCumulus
git fetch --all
git checkout tags/rel/$1
if [ $? != 0 ]; then echo "ERROR: Failed to checkout tag rel/$1"; exit 1; fi
   
# Go back to the CumulusTemplate workspace
cd "$workspace"

# Update package versions in version.properties
echo "Updating version.properties file"
while read line; do
    if [[ $line == 'version.npsp='* ]]; then
        namespace='version.npsp'
        namespace_version=$1
    else
        namespace=`echo "$line" | sed -e 's/=.*//g'`
        namespace_version=`echo "$line" | sed -e 's/version\..*=//g'`
    fi
    sed -e "s/$namespace=.*/$namespace=$namespace_version/g" version.properties > version.properties.new
    mv version.properties.new version.properties
done < ../CumulusTemplateCumulus/version.properties

# Update the currently installed version in a target org for GW_Volunteers and pub
# NOTE: This requires a build.properties in the root of the repo for target org credentials
ant getPackageVersions > package_versions.txt
version_GW_Volunteers=`grep '\[echo\] GW_Volunteers:' package_versions.txt | sed -e 's/.*\[echo\] GW_Volunteers: //g' | sed -e 's/ .*$//g'`
version_pub=`grep '\[echo\] pub:' package_versions.txt | sed -e 's/.*\[echo\] pub: //g' | sed -e 's/ .*$//g'`
sed -e "s/version.GW_Volunteers=.*/version.GW_Volunteers=$version_GW_Volunteers/g" version.properties > version.properties.new
mv version.properties.new version.properties
sed -e "s/version.pub=.*/version.pub=$version_pub/g" version.properties > version.properties.new
mv version.properties.new version.properties
rm package_versions.txt

# Fetch the latest managed layouts from all packages
ant fetchManagedLayouts
if [ $? != 0 ]; then echo "ERROR: Failed to fetch managed layouts"; exit 1; fi

# Checkout the previous release of Cumulus the template was configured against to look for new metadata
cd ../CumulusTemplateCumulus
git diff tags/rel/$previous_version tags/rel/$1 -- src/package.xml | \
    grep '^+ ' | \
    sed -e 's/^+  *//g' > "$workspace/new_metadata.diff"

# Create report of new metadata grouped by type and save as new_metadata.md
cd "$workspace"
echo "# New Metadata from $previous_version to $1" > new_metadata.md
echo "" > new_metadata.md

in_type=0
if [ -f new_metadata.type ]; then rm new_metadata.type; fi

while read line; do
    if [ "`echo \"$line\" | grep '<types>'`" != '' ]; then
        in_type=1
        continue
    fi
    if [ "$in_type" == "1" ]; then
        # If the line contains <name>, close out the type section
        if [ "`echo \"$line\" | grep '<name>'`" != '' ]; then
            in_type=0
            if [ -f new_metadata.type ]; then
                type_name=`echo "$line" | sed -e 's/^.*<name>\(.*\)<\/name>/\1/g'`
                echo "## $type_name" >> new_metadata.md
                while read member; do
                    echo "* $member" >> new_metadata.md
                done < new_metadata.type
                echo "" >> new_metadata.md
            fi
            if [ -f new_metadata.type ]; then rm new_metadata.type; fi
            type_name=''
            continue
        fi

        # If the member is listed in new_metadata.diff, add it to new_metadata.type
        match_str=`echo "$line" | sed -e 's/^.*<members/<members/g'`
        if [ "`grep \"$match_str\" new_metadata.diff`" != '' ]; then
            member_name=`echo "$match_str" | sed -e 's/^.*<members>\(.*\)<\/members>/\1/g'`
            echo $member_name >> new_metadata.type
            continue
        fi
    fi
done < ../CumulusTemplateCumulus/src/package.xml

rm new_metadata.diff

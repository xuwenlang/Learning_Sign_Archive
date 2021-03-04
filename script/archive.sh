# distribution method (App Store Connect、Ad Hoc、Enterprise、Development）
#
# 该脚本导出的ipa方式（在ExportOptionsPlist文件里配置）
# Staging和Release都选择了Enterprise
#
# cd到本脚本文件的当前目录执行此脚本


cd ..

# 选择编译方式开始
echo "请选择您要编译的配置 ? [ 1: Staging 2: Release] "
read number
while([[ $number != 1 ]] && [[ $number != 2 ]])
do
echo "错误! 应该输入 1 or 2"
echo "请选择您要编译的配置 ? [ 1: Staging 2: Release] "
read number
done
if [ $number == 1 ]; then
BuildConfiguration="Staging"
SeviceTypeName="测试服"
ExportOptionsPlist=ios_scripts/ExportOptions-Enterprise.plist
elif [ $number == 2 ]; then
BuildConfiguration="Release"
SeviceTypeName="正式服"
ExportOptionsPlist=ios_scripts/ExportOptions-Enterprise.plist
fi
# 选择编译方式结束


# 设置版本号开始
rx='^([0-9]+\.){0,2}(\*|[0-9]+)$'

echo "请输入App Store版本号："
read versionNumber
if [[ $versionNumber =~ $rx ]]; then
    xcrun agvtool new-marketing-version ${versionNumber}
else
    echo "不设置App Store版本号..."
fi

echo "请输入Build号："
read buildNumber
if [[ $buildNumber =~ $rx ]]; then
    xcrun agvtool new-version -all ${buildNumber}
else
    echo "不设置Build版本号..."
fi
# 设置版本号结束


# 开始配置参数
appVersionNumder=$(xcrun agvtool what-marketing-version -terse1)
buildNumber=$(xcrun agvtool what-version -terse)
WORKSPACE_NAME="CRPharmacist.xcworkspace"
SCHEME_NAME="CRPharmacist"
AppDisplayName="药师"
BUILD_DATE=`date +%Y-%m-%d_%H.%M.%S`
ArchivePath=ios_ipaFiles/${BuildConfiguration}/${SCHEME_NAME}_${BUILD_DATE}.xcarchive
ExportPath=ios_ipaFiles/${BuildConfiguration}


# 开始编译

echo "正在清理工程..."
xcodebuild clean -workspace ${WORKSPACE_NAME} -scheme ${SCHEME_NAME} -configuration ${BuildConfiguration} -sdk iphoneos

echo "正在归档..."
xcodebuild archive -workspace ${WORKSPACE_NAME} -scheme ${SCHEME_NAME} -configuration ${BuildConfiguration} -sdk iphoneos -archivePath ${ArchivePath} -UseModernBuildSystem=YES

echo "正在导出..."
xcodebuild -exportArchive -archivePath ${ArchivePath} -exportPath ${ExportPath} -exportOptionsPlist ${ExportOptionsPlist}

# ipa文件改名
OldFileName=${ExportPath}/${SCHEME_NAME}.ipa
NewFileName=${ExportPath}/${AppDisplayName}_iOS_Version${appVersionNumder}"("${buildNumber}")"_${BuildConfiguration}_${SeviceTypeName}.ipa

echo $appVersionNumder
echo $buildNumber
echo $NewFileName
mv ${OldFileName} ${NewFileName}

open ./ios_ipaFiles

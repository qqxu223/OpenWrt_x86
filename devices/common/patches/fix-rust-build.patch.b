--- a/feeds/packages/lang/rust/Makefile
+++ b/feeds/packages/lang/rust/Makefile
@@ -75,7 +75,7 @@
 	--release-channel=stable \
 	--enable-cargo-native-static \
 	--bootstrap-cache-path=$(DL_DIR)/rustc \
-	--set=llvm.download-ci-llvm=true \
+	--set=llvm.download-ci-llvm=false \
 	$(TARGET_CONFIGURE_ARGS)
 
 define Host/Uninstall


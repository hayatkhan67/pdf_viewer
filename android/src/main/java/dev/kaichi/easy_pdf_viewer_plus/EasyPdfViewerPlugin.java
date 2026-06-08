package dev.kaichi.easy_pdf_viewer_plus;

import android.annotation.SuppressLint;
import android.os.Build;
import android.os.HandlerThread;
import android.os.Process;
import android.os.Handler;
import android.os.Looper;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.pdf.PdfRenderer;
import android.os.ParcelFileDescriptor;

import androidx.annotation.NonNull;

import java.io.File;
import java.io.FileOutputStream;
import java.io.FilenameFilter;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** EasyPdfViewerPlugin */
public class EasyPdfViewerPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native
  /// Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine
  /// and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private FlutterPluginBinding instance;
  private Handler backgroundHandler;
  private final Object pluginLocker = new Object();
  private final String filePrefix = "FlutterEasyPdfViewerPlugin";

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "easy_pdf_viewer_plugin");
    channel.setMethodCallHandler(this);
    instance = flutterPluginBinding;
  }

  @Override
  public void onMethodCall(@NonNull final MethodCall call, @NonNull final Result result) {
    synchronized (pluginLocker) {
      if (backgroundHandler == null) {
        HandlerThread handlerThread = new HandlerThread("flutterEasyPdfViewer", Process.THREAD_PRIORITY_BACKGROUND);
        handlerThread.start();
        backgroundHandler = new Handler(handlerThread.getLooper());
      }
    }

    final Handler mainThreadHandler = new Handler(Looper.getMainLooper());

    backgroundHandler.post(//
        new Runnable() {
          @Override
          public void run() {
            switch (call.method) {
              case "getNumberOfPages":
                final String numResult = getNumberOfPages((String) call.argument("filePath"),
                    (boolean) call.argument("clearCacheDir"));
                mainThreadHandler.post(new Runnable() {
                  @Override
                  public void run() {
                    result.success(numResult);
                  }
                });
                break;
              case "getPage":
                final String pageRes = getPage((String) call.argument("filePath"), (int) call.argument("pageNumber"));
                mainThreadHandler.post(new Runnable() {
                  @Override
                  public void run() {
                    result.success(pageRes);
                  }
                });
                break;
              case "clearCacheDir":
                clearCacheDir();
                mainThreadHandler.post(new Runnable() {
                  @Override
                  public void run() {
                    result.success(null);
                  }
                });
                break;
              default:
                result.notImplemented();
                break;
            }
          }
        });
  }

  private void clearCacheDir() {
    try {
      File directory = instance.getApplicationContext().getCacheDir();
      FilenameFilter myFilter = new FilenameFilter() {
        @Override
        public boolean accept(File dir, String name) {
          return name.toLowerCase().startsWith(filePrefix.toLowerCase());
        }
      };
      File[] files = directory.listFiles(myFilter);
      // Log.d("Cache Files", "Size: " + files.length);
      assert files != null;
      for (File file : files) {
        // Log.d("Files", "FileName: " + files[i].getName());
        file.delete();
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
  }

  @SuppressLint("DefaultLocale")
  private String getNumberOfPages(String filePath, boolean clearCacheDir) {
    File pdf = new File(filePath);
    try {
      if (clearCacheDir) {
        clearCacheDir();
      }
      PdfRenderer renderer = new PdfRenderer(ParcelFileDescriptor.open(pdf, ParcelFileDescriptor.MODE_READ_ONLY));
      try {
        final int pageCount = renderer.getPageCount();
        return String.format("%d", pageCount);
      } finally {
        renderer.close();
      }
    } catch (Exception ex) {
      ex.printStackTrace();
    }
    return null;
  }

  private String getFileNameFromPath(String name) {
    String filePath = name.substring(name.lastIndexOf('/') + 1);
    filePath = filePath.substring(0, filePath.lastIndexOf('.'));
    return String.format("%s-%s", filePrefix, filePath);
  }

  private String createTempPreview(Bitmap bmp, String name, int page) {
    String fileNameOnly = getFileNameFromPath(name);
    File file;
    try {
      @SuppressLint("DefaultLocale")
      String fileName = String.format("%s-%d.png", fileNameOnly, page);
      file = File.createTempFile(fileName, null, instance.getApplicationContext().getCacheDir());
      FileOutputStream out = new FileOutputStream(file);
      bmp.compress(Bitmap.CompressFormat.PNG, 100, out);
      out.flush();
      out.close();
    } catch (Exception e) {
      e.printStackTrace();
      return null;
    }
    return file.getAbsolutePath();
  }

  private String getPage(String filePath, int pageNumber) {
    File pdf = new File(filePath);

    try {
      PdfRenderer renderer = new PdfRenderer(ParcelFileDescriptor.open(pdf, ParcelFileDescriptor.MODE_READ_ONLY));
      final int pageCount = renderer.getPageCount();
      if (pageNumber > pageCount) {
        pageNumber = pageCount;
      }

      PdfRenderer.Page page = renderer.openPage(--pageNumber);
      double width = page.getWidth();
      double height = page.getHeight();
      final double docRatio = width / height;

      width = 2048;
      height = (int) (width / docRatio);

      Bitmap bitmap = Bitmap.createBitmap((int) width, (int) height, Bitmap.Config.ARGB_8888);
      Canvas canvas = new Canvas(bitmap);
      canvas.drawColor(Color.WHITE);
      page.render(bitmap, null, null, PdfRenderer.Page.RENDER_MODE_FOR_DISPLAY);
      try {
        return createTempPreview(bitmap, filePath, pageNumber);
      } finally {
        page.close();
        renderer.close();
      }
    } catch (Exception ex) {
      System.out.println(ex.getMessage());
      ex.printStackTrace();
    }

    return null;
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
    instance = null;
  }
}
